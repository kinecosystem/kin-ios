//
//  KeyTests.swift
//  KinBaseTests
//
//  Created by Kik Interactive Inc.
//  Copyright © 2021 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinBase

class KeyTests: XCTestCase {
    
    func testOffCurve() {
        let offCurvePublicKeys = Key32.offCurveKeys()
        offCurvePublicKeys.forEach {
            XCTAssertFalse($0.isOnCurve())
        }
    }
    
    func testOnCurve() {
        (0..<100000).forEach { _ in
            let pair = KeyPair.generate()!
            XCTAssertTrue(pair.publicKey.isOnCurve())
        }
    }
}

private extension Key32 {
    static func offCurveKeys() -> [Key32] {
        [
            "GvjjP54e6jpf92EoWdcezH9WKXCN52yPZBWbw4ppviUa",
            "AgKiznCRVoNvF1dSDjpDBXMvQhQdGyPCG1A4BwpUwZTr",
            "9hEDaPgirQm4mq42YCNToQnsCYB3an6qcpQZsWCE9zrR",
            "4oGhXQGeEow3ocwRksCBGZpoPBrDZ8GGEh8UsTsugGNt",
            "2coUDSZZLHn4rcNK4djLfeQ6Y5NCy3zy78KrXKmk5PF6",
            "94fCEu2UETKPEZGUMLXboFuWKRmULjopFoca6ZdWNM8r",
            "Cnrj6KSjsY5jgnuGPVvz2RKCfhc2tJSKKi6sQUqHWDwz",
            "3FCH66tfSJMJZJfr36a4h6sZ3ycY3UZ4S5dDZe7yscK3",
            "HvZR52R7xD9528CmZ73HtBf4AzDHhejNu7bByMBEmV1D",
            "6zkkLYRaYwkB4HPxExnRz9LicUFv7czJJQMPpVYu1uxJ",
            "FZJpBNhnVqGRH5e7YWd6p8JJWVEADZQ6LdwJ8pgzZzrC",
            "4csJzW1bRFhGyGLzFH1Qf5Z1AGAbq8e7r4E5uD3j4Mv2",
            "Co7LsrvJ2MPhnBtSN9qASGq9UqvhTbJMVZffeFYmBVNy",
            "91Nf9tVBrRCWiH62c9JWYanQ4y9pFhGbyAwZatgi4m3L",
            "U5nRSxsUAA2nD1J9TD1RwtHZ5KAXiZH1YUbh5ivgWqQ",
            "A912q2P9UyzYWf8SnETJP8KsyLNgc6YSSqUiUjMgfzmq",
            "9J4o7p1fCHL1uUoCE98uGuLmUy8PsBJr39bX5B2Nd4vY",
            "da6QpWw8YFP1AkuJE1bBuVHur9EPi2giLSrMeJ7eNTY",
            "6aE3pUeaK1dKgXi1Rii3Cx8358Fk2GrMg3VCEN8pz6un",
            "8h1UeKm7pC2HbmiVC9BB93azGDxc6L1mfXjtcSf3DEUT",
            "5EJcMWRjVHJUWCbBqsFAoxT8S3c9RbjfQkbW8JnZ2JMj",
            "HQRBafKtwmXxxKn6K4FDZ5dUjxMb76oPxKqSXASy8xVx",
            "DtzsE9oskQsP57xr837L4gBZERHBGG8WVS6BYcjLJ6sB",
            "AZnkNCcLg6WRXckDvbxGmbFupkqpfccPEApHfCWJHJiM",
            "BYftM6s1sM9H5THi1F6DomC4gKpvbhcfBT8XkyoU5eob",
            "DtJocjkBZK9rxkL9MShrU6prVkufeTuRL3X7Yf4mEfAb",
            "C2QDoG3sCLGS8wniwcF17sdwFQtkgwFwzodfUmbzpAxA",
            "B4pSrtaynrBh2Pp3SoNyN1bqAdZ4MErbzFAW8sUn8pta",
            "GsA7za4sN6vzRogW5woSj5oeNAqK6HM8D9ZgSijVHcQJ",
            "BMnydqAZsdCUBiHya5RwYwBczZKys1DT1a2kbEmdWc5i",
            "D7Mu6hB79Hw1rR2cjSXPCZxQt1XBUioMy1yLufsvyuk6",
            "BN6GnXPv6HPoiExE5rCHDcXp7mv7W9AfAHXDWHFPRKpC",
            "Cu64TtgmjqjpG2UJqgDohWNDcm7JQ5QhWoS9t69usY6J",
            "61YE6Y93bCDirwH8V5Qhbui42EuZu89SnQDmdAwpDGsH",
            "GrbovtgJP7cpPBXvj8UPx22nZhzgW4aSLwQcefDkQQK1",
            "EhfSmzJ8YLeojvnJDs1e2BTwpmoxaQoimdoH94nuY1Bt",
            "7A1KMyUwj33R9wM5qTQaui6tf7QM6CmX7RrPTwWVMVxV",
            "GBrp8327ieEEnkwCiEzqkh8h7FEPxD5vmnR2hMHiQypS",
            "BEG4NGrn5Jxj1QgZQbfciWXNfcXiatXaJ9Fh4S5srTfZ",
            "CLCFK4PYQY3u1RrtSDEftVTxrcRGztSG72ijDFDDVQ3o",
            "Br9PHMsWJw8Wy7kwgi9h38qtVETwCtFEW1sK26AeHLoq",
            "CFvx8FJPP7gMknwUA2YDQALwP9npNv5VQDL6PxUCFFbn",
            "5pjzYxCZocnysiLg78gDgXZY5g5rFSpoMsbUiFJSqTb3",
            "ERjjBWQkd8vZLZ1ApHsXpPYiSximg4euWMqF5yAsMra1",
            "3g9cU3fL4hQivZ3eU5VXCpALZ8ZLP2zVj1Atr3wM9wq1",
            "A8MN1cpd8gBrwWGNvUDF6Ezv5toDQ617eabCVfRmcXMR",
            "Dj4kbfrLvzUvB67sy83Y83zg8WFm2EWxzgNvtLkiNT9X",
            "J9whewsmYJv2sasaWeXmCR4dQCT63syBNMcLDArX9Xrc",
            "aBPi5Qjj6iK4G6sANYQJjEQrFDQ3edVTceK1yLW3Ux9",
            "F2EJCKx12sozEFM72p6tA7tCv1XfFEvKJSZB5QNzNdwh",
            "EoQ3xMQnWB2ragpUFh1e3aSqxVmyq9MdT8wcUnxhuqBz",
            "62LuuYipcurVGRbZpHXnkep1FNf5G8YztP9qHwd8EjBb",
            "AYJXw3BebkbqaD29v1a7P5MasZaGv8w6fJvMatt4K4wT",
            "B2Qas8fSLWd8Jxip4JTXyHQuRRNZL4GRtrmG1pBcAZYQ",
            "AuATNiXwLdC2t8Nm6azxECKm68GEEkzEtvQgEkixZrBY",
            "EB1eDWBSJoRkyditx7QEZjSEqtHvdwsqKC7xhjaDUsLN",
            "DKnsHP7d6sSWyNxyTgpiyKxgQWPCBkNaqamWHFWw8r3i",
            "BPkumkSDBs37mkK7UUDzoQxfcVxynaNr4aktukUog7q5",
            "7e2jg9Wn67G2v7JRLKxKte6hYogDsFk5VSHjkAqRQ4fK",
            "F2U5Gz4fz1P8LFZpCgXy3MwR5ZYaUopThk9wZHn3cBY1",
            "91qtbq62a9yzfts1W1JY1FD7HoPKt9wZihsJ4zCGq2Ry",
            "ByYHVyoxdT7DLU3XzFqKmy4t4h2YGisHi4vX9uxFmCg5",
            "CTiM5fPVCZGN4BgttD3PRqF4HGhKBpfBSS1ctn4zfXgG",
            "4bemZ5WmPEitirdp27zKW4mcZwE1US7AqjahPzoEyoB6",
            "6bCaEQvzNtwPvBUiYL1EteLiWU5cgEYjaQ11bi1eZCaB",
            "74vQWTi8WUXXssX4fRpx1eTnsxM8rQpNae33PhLn7q4F",
            "F5f2b5AM9XdjWg7M6juAev4GH7DkQfp5b1aGPDGuTmpm",
            "GCH7rULKkb1Xd9iQjcpGuSqrhFkCaAkiE6s4Rp7QNE2Z",
            "HrM9Ypto7oiUXB6ccLdZQqzKZ1fDL2VWRf1ivZSezaji",
            "CypuuWor58kPf8WA3drCGDDjtbQaxRh1s4DnzUvhpSwY",
            "Bi3fY8vVkxzBzz9PYPS7zqqtvgD8wHbsX2Ec4crH1NB1",
            "Pkm3yxYeAUKsKNLWMW1mCuFKsqELNY6fcna5aausVXP",
            "DavsMfmaZ9LLLGMwpPMAYV4TPnPqXaaqaKfX8DMhSZnb",
            "XVsm1xMzhVgSdYeeucyuWF73irPWZtvHaopqVJnLNVm",
            "HS59q3WJw5zZx48J8GrvfMFyBwHSTcbqoxfcZwzDX64a",
            "4xXxdaPJwBKsz7y7xhdGiLiZkoVTRH8SEvdcmArEGC5m",
            "Hh5bLrzuaj5pSckks1i4ZuWjYyHuzDdgVtBacCyunK68",
            "BivmZYz9R5WTgAqdTKeSAj7CNdGYnHhjRbdieHK9nkPx",
            "7u8We3JwbpUUeqTN4HaYNyoLY5CB9wEWnQdZx81dDq2V",
            "CjAN2QfnMTQZ7Fj39kRe3CmahEC9W4L5mL1jfE5u71GC",
            "2zif5Jd742xousqiU6abYMiGv9ZRLViV1thZM995fkUo",
            "B7TfeGaExZxRJUJFXz92zpQwApZkioA7CeRcX9GZYnWt",
            "AsPucskjGocxDSdkHPn5BFtYxR8U9odzv8UkingtUp8X",
            "UE1x7k8bc4QKWS4VQ6rsaj6qsnVZkuv6k3AvEAWMCN9",
            "Dxs3UWmsMiSJ86Gv6pYgkhYXn6KGNmbpLMfwdJvgY8SS",
            "GAezGp5BY3dt29ByYBUg2PDtuMoKgJzGHYLe8JMdbppQ",
            "9SGqvEKzPpkpjawqCjYFmHrm6JQMJdpWq8P1VNKchf1C",
            "3Wb6P6sjETkFefvRjXG3FStFWjptCKswiZGjnanToBy7",
            "D8zAqsadQeBaQw5x4UQ2atL59GWPRHucGsUWfTVRpt2j",
            "4juMXpUQhYq43E4JBYXWFZvNJgRwDXnStfcm2qMMQ34z",
            "Hndmrfd6WwcUufxRvTyUvMeyDtFEn6kRyu9RbZPg7K16",
            "5oV2jM6XHmqAoA55Nit9AGWwi9uFX1nH6My6vfFX1Yy6",
            "9uagoG1QBizcj6yyJoxJE1TGPi8PseWJVUi8LoDukAKv",
            "EbjmvXrDxCSdrnaYuJRMJLbZurAAB5uYZnLm4SAW2k9i",
            "8raeR59TuDKeALZ9zdwJicaq5s4sYMYuB2tWwqgUUd6o",
            "nTno6tuMTB9yMYp5SLDPmfEcnX6JdFhsm5hGSHWbwGx",
            "A6a2nzHMc4torXbGtcabX621JGFywtbiThxzGx5RSNZu",
            "5prX9b1pCCLjFJ7vArUYHkhx8RjRDJ4idvuPTXV3zegk",
            "EFL28wiQHuS4FKAod1FPKN7mkoMFPcBGHyA4T9DF6amg",
            "JBFk7R2LPyjNsjdS1keWUrAy2VUWq2gsNccqYXRnRns1",
            "9TnYjKW5F4NjNSLRUTbta4gA8NvpfsN9MxrCuStQ2BBy",
        ].map { Key32(base58: $0)! }
    }
}
