/*
 * Copyright 2015, alex at staticlibs.net
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* 
 * File:   openssl_test.cpp
 * Author: alex
 *
 * Created on February 9, 2015, 12:35 PM
 */

#include <cstdlib>
#include <cstdio>
#include <cstring>

#include <openssl/aes.h>

// http://stackoverflow.com/a/10082316
static const unsigned char key[] = {
    0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77,
    0x88, 0x99, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff,
    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
};

int main() {
    unsigned char text[] = "hello world!";
    unsigned char* enc_out = static_cast<unsigned char*>(malloc(80 * sizeof(char)));
    memset(enc_out, 0, 80 * sizeof (char));
    unsigned char* dec_out = static_cast<unsigned char*>(malloc(80 * sizeof(char)));    
    memset(enc_out, 0, 80 * sizeof (char));

    AES_KEY enc_key, dec_key;

    AES_set_encrypt_key(key, 128, &enc_key);
    AES_encrypt(text, enc_out, &enc_key);


    AES_set_decrypt_key(key, 128, &dec_key);
    AES_decrypt(enc_out, dec_out, &dec_key);

    int i;

    printf("original:\t");
    for (i = 0; *(text + i) != 0x00; i++) {
        printf("%X ", *(text + i));
    }
    printf("\nencrypted:\t");
    for (i = 0; *(enc_out + i) != 0x00; i++) {
        printf("%X ", *(enc_out + i));
    }
    printf("\ndecrypted:\t");
    for (i = 0; *(dec_out + i) != 0x00; i++) {
        printf("%X ", *(dec_out + i));
    }
    printf("\n");
    free(enc_out);
    free(dec_out);

    return 0;
}

