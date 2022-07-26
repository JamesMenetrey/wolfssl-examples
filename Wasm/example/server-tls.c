/* server-tls.c
 *
 * Copyright (C) 2006-2020 wolfSSL Inc.
 *
 * This file is part of wolfSSL. (formerly known as CyaSSL)
 *
 * wolfSSL is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * wolfSSL is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
 */

#include "server-tls.h"

/* the usual suspects */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

/* socket includes */
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <unistd.h>

/* wolfSSL */
#include <wolfssl/ssl.h>
#include <wolfssl/certs_test.h>

#ifdef __wasi__
#include "wasi_socket_ext.h"
#endif

#define DEFAULT_PORT 11111

#define CIPHER_LIST "ECDHE-ECDSA-AES128-GCM-SHA256"

int server_connect()
{
    int                sgxStatus;
    int                sockfd;
    int                connd;
    struct sockaddr_in servAddr;
    struct sockaddr_in clientAddr;
    socklen_t          size = sizeof(clientAddr);
    char               buff[256];
    size_t             len;
    int                ret = 0;                        /* variable for error checking */
    const char*        reply = "I hear ya fa shizzle!\n";

    /* declare wolfSSL objects */
    WOLFSSL_CTX* ctx;
    WOLFSSL* ssl;
    WOLFSSL_METHOD* method;



    /* Initialize wolfSSL */
    wolfSSL_Init();

    wolfSSL_Debugging_ON();

    /* Create a socket that uses an internet IPv4 address,
     * Sets the socket to be stream based (TCP),
     * 0 means choose the default protocol. */
    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
        fprintf(stderr, "ERROR: failed to create the socket\n");
        return -1;
    }


    /* Create and initialize WOLFSSL_CTX */
    method = wolfTLSv1_2_server_method();

    
    long id = -1;
    ctx = wolfSSL_CTX_new(method);

    if (ctx < 0) {
        printf("wolfSSL_CTX_new failure\n");
        return -1;
    }

    /* Load server certificates into WOLFSSL_CTX */
    ret = wolfSSL_CTX_use_certificate_buffer(ctx, server_cert_der_2048, sizeof_server_cert_der_2048, SSL_FILETYPE_ASN1);
    if (ret != SSL_SUCCESS) {
        printf("wolfSSL_CTX_use_certificate_buffer failure\n");
        return -1;
    }
    

    /* Load server key into WOLFSSL_CTX */
    ret = wolfSSL_CTX_use_PrivateKey_buffer(ctx, server_key_der_2048, sizeof_server_key_der_2048, SSL_FILETYPE_ASN1);
    if (ret != SSL_SUCCESS) {
        printf("wolfSSL_CTX_use_PrivateKey_buffer failure\n");
        return EXIT_FAILURE;
    }

    /* Initialize the server address struct with zeros */
    memset(&servAddr, 0, sizeof(servAddr));
    /* Fill in the server address */
    servAddr.sin_family      = AF_INET;             /* using IPv4      */
    servAddr.sin_port        = htons(DEFAULT_PORT); /* on DEFAULT_PORT */
    servAddr.sin_addr.s_addr = INADDR_ANY;          /* from anywhere   */



    /* Bind the server socket to our port */
    if (bind(sockfd, (struct sockaddr*)&servAddr, sizeof(servAddr)) == -1) {
        fprintf(stderr, "ERROR: failed to bind\n");
        return -1;
    }

    /* Listen for a new connection, allow 5 pending connections */
    if (listen(sockfd, 5) == -1) {
        fprintf(stderr, "ERROR: failed to listen\n");
        return -1;
    }

    printf("Waiting for a connection...\n");

    /* Accept client connections */
    if ((connd = accept(sockfd, (struct sockaddr*)&clientAddr, &size))
        == -1) {
        fprintf(stderr, "ERROR: failed to accept the connection\n\n");
        return -1;
    }

    ssl = wolfSSL_new(ctx);
    if (ssl < 0) {
        printf("wolfSSL_new failure\n");
        return -1;
    }

    /* Attach wolfSSL to the socket */
    ret = wolfSSL_set_fd(ssl, connd);
    if (ret != SSL_SUCCESS) {
        printf("wolfSSL_set_fd failure\n");
        return -1;
    }

    printf("Client connected successfully\n");

    /* Read the client data into our buff array */
    memset(buff, 0, sizeof(buff));

    ret = wolfSSL_read(ssl, buff, sizeof(buff)-1);
    if(ret == -1) {
        printf("Server failed to read\n");
        return -1;
    }

    /* Print to stdout any data the client sends */
    printf("Client: %s\n", buff);

    /* Write our reply into buff */
    memset(buff, 0, sizeof(buff));
    memcpy(buff, reply, strlen(reply));
    len = strnlen(buff, sizeof(buff));

    /* Reply back to the client */
    ret = wolfSSL_write(ssl, buff, len);
    if (ret != len) {
        printf("Server write failed.\n");
        return -1;
    }

    /* Cleanup after this connection */
    wolfSSL_free(ssl);      /* Free the wolfSSL object              */
    close(connd);           /* Close the connection to the client   */

    /* Cleanup and return */
    wolfSSL_CTX_free(ctx);  /* Free the wolfSSL context object          */
    wolfSSL_Cleanup();      /* Cleanup the wolfSSL environment          */
    close(sockfd);          /* Close the socket listening for clients   */
    return 0;               /* Return reporting a success               */
}