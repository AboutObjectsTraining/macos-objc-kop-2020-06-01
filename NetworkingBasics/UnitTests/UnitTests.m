// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import <XCTest/XCTest.h>
#import <CoreFoundation/CoreFoundation.h>

#import <Network/Network.h>

#include <err.h>
#include <errno.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
//#include <sys/socket.h>

#include <netinet/in.h>
#include <arpa/inet.h>


/* --- PRINTF_BYTE_TO_BINARY macro's --- */
#define PRINTF_BINARY_PATTERN_INT8 "%c%c%c%c%c%c%c%c "
#define PRINTF_BYTE_TO_BINARY_INT8(i)    \
(((i) & 0x80ll) ? '1' : '0'), \
(((i) & 0x40ll) ? '1' : '0'), \
(((i) & 0x20ll) ? '1' : '0'), \
(((i) & 0x10ll) ? '1' : '0'), \
(((i) & 0x08ll) ? '1' : '0'), \
(((i) & 0x04ll) ? '1' : '0'), \
(((i) & 0x02ll) ? '1' : '0'), \
(((i) & 0x01ll) ? '1' : '0')

#define PRINTF_BINARY_PATTERN_INT16 \
PRINTF_BINARY_PATTERN_INT8              PRINTF_BINARY_PATTERN_INT8
#define PRINTF_BYTE_TO_BINARY_INT16(i) \
PRINTF_BYTE_TO_BINARY_INT8((i) >> 8),   PRINTF_BYTE_TO_BINARY_INT8(i)
#define PRINTF_BINARY_PATTERN_INT32 \
PRINTF_BINARY_PATTERN_INT16             PRINTF_BINARY_PATTERN_INT16
#define PRINTF_BYTE_TO_BINARY_INT32(i) \
PRINTF_BYTE_TO_BINARY_INT16((i) >> 16), PRINTF_BYTE_TO_BINARY_INT16(i)
#define PRINTF_BINARY_PATTERN_INT64    \
PRINTF_BINARY_PATTERN_INT32             PRINTF_BINARY_PATTERN_INT32
#define PRINTF_BYTE_TO_BINARY_INT64(i) \
PRINTF_BYTE_TO_BINARY_INT32((i) >> 32), PRINTF_BYTE_TO_BINARY_INT32(i)
/* --- end macros --- */

const char *ipv4_zero = "0.0.0.0";
char ipv4_name[INET_ADDRSTRLEN] = "192.168.254.123";

void read_from_connection(nw_connection_t connection);

@interface UnitTests : XCTestCase

@end

@implementation UnitTests

- (void)testConvertPresentationToNetworkAddress {
    struct in_addr ipv4_address;
    
    int result = inet_pton(AF_INET, ipv4_name, &ipv4_address);
    in_addr_t swapped_address = CFSwapInt32BigToHost(ipv4_address.s_addr);

    switch (result) {
        case 0: XCTFail("Invalid address: %s", ipv4_name); break;
        case 1: printf("Address %s in hex is %x\n", ipv4_name, swapped_address); break;
        default: XCTFail("Bad status %d", errno);
    }
    printf("%x in binary is " PRINTF_BINARY_PATTERN_INT32 "\n", swapped_address, PRINTF_BYTE_TO_BINARY_INT32(swapped_address));
}

- (void)testConvertNetworkAddressToPresentation {
    struct in_addr ipv4_address;
    
    inet_pton(AF_INET, ipv4_name, &ipv4_address);
    
    in_addr_t swapped_address = CFSwapInt32BigToHost(ipv4_address.s_addr);
    printf("%x in binary is " PRINTF_BINARY_PATTERN_INT32 "\n", swapped_address, PRINTF_BYTE_TO_BINARY_INT32(swapped_address));
    
    const char *presentation = inet_ntop(AF_INET, &ipv4_address, ipv4_name, sizeof(ipv4_name));
    if (presentation == NULL || strncmp(presentation, ipv4_zero, strlen(ipv4_zero)) == 0) {
        XCTFail("Invalid address %s", ipv4_name);
    }
    printf("%x presentation is %s\n", ipv4_address.s_addr, presentation);
}

- (void)testNetworkConnection {
    nw_endpoint_t endpoint = (nw_endpoint_create_host("www.aboutobjects.com", "443"));
    
    nw_parameters_configure_protocol_block_t configure_tls = NW_PARAMETERS_DISABLE_PROTOCOL;
    nw_parameters_t parameters = nw_parameters_create_secure_tcp(configure_tls, NW_PARAMETERS_DEFAULT_CONFIGURATION);

    nw_connection_t connection = nw_connection_create(endpoint, parameters);
    nw_connection_set_queue(connection, dispatch_get_main_queue());
    
//    nw_retain(connection); // Hold a reference until cancelled
    nw_connection_set_state_changed_handler(connection, ^(nw_connection_state_t state, nw_error_t error) {
        nw_endpoint_t remote = nw_connection_copy_endpoint(connection);
        errno = error ? nw_error_get_error_code(error) : 0;
        if (state == nw_connection_state_waiting) {
            warn("connect to %s port %u failed, is waiting",
                 nw_endpoint_get_hostname(remote),
                 nw_endpoint_get_port(remote));
        } else if (state == nw_connection_state_failed) {
            warn("connect to %s port %u failed",
                 nw_endpoint_get_hostname(remote),
                 nw_endpoint_get_port(remote));
        } else if (state == nw_connection_state_ready) {
            fprintf(stderr, "Connection to %s port %u succeeded!\n",
                    nw_endpoint_get_hostname(remote),
                    nw_endpoint_get_port(remote));
        } else if (state == nw_connection_state_cancelled) {
//            nw_release(connection);
        }
//        nw_release(remote);
    });
    
    nw_connection_start(connection);
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3]];
    read_from_connection(connection);
}


@end

void read_from_connection(nw_connection_t connection) {
    nw_connection_receive(connection, 1, UINT32_MAX,
                          ^(dispatch_data_t content,
                            nw_content_context_t context,
                            bool is_complete,
                            nw_error_t receive_error) {
        
        dispatch_block_t schedule_next_receive = ^{
            // If the context is marked as complete, and is the final context,
            // we're read-closed.
            if (is_complete &&
                context != NULL && nw_content_context_get_is_final(context)) {
                exit(0);
            }
            
            // If there was no error in receiving, request more data
            if (receive_error == NULL) {
                read_from_connection(connection);
            }
        };
        
        if (content != NULL) {
            // If there is content, write it to stdout asynchronously
            dispatch_write(STDOUT_FILENO, content, dispatch_get_main_queue(), ^(__unused dispatch_data_t _Nullable data, int stdout_error) {
                if (stdout_error != 0) {
                    errno = stdout_error;
                    warn("stdout write error");
                } else {
                    schedule_next_receive();
                }
                //                Block_release(schedule_next_receive);
            });
        } else {
            // Content was NULL, so directly schedule the next receive
            schedule_next_receive();
        }
    });
}


