//
//  Invoices.swift
//  KinBase
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import Foundation

public struct SKU: Equatable {
    /// can by up to 128 bytes in size
    public let bytes: [Byte]

    public init(bytes: [Byte]) {
        self.bytes = bytes
    }
}

/// An individual item in an `Invoice`
public struct LineItem: Equatable {
    public enum LineItemFormatError: String, Error {
        case invalidTitle = "Invalid title length. Must be > 1 and <= 128 characters"
        case descriptionTooLong = "Invalid description length. Must be <= 256 characters"
        case skuTooLong = "SKU cannot exceed 128 bytes"
    }

    public let title: String
    public let description: String?
    public let amount: Kin
    public let sku: SKU?

    /// Performs format check and initializes a `LineItem`.
    /// - Parameters:
    ///   - title: 1-128 characters of renderable text describing the item.
    ///   - description: optional 0-256 characters of renderable text describing the item.
    ///   - amount: the amount of Kin that the item costs.
    ///   - sku: an app defined identifier to key the `LineItem` on. Should at least be unique per item, if not per item + user who is purchasing it.
    /// - Throws: `LineItemFormatError`
    public init(title: String,
                description: String? = nil,
                amount: Kin,
                sku: SKU? = nil) throws {
        guard !title.isEmpty, title.count <= 128 else {
            throw LineItemFormatError.invalidTitle
        }

        self.title = title

        if let description = description, description.count > 256 {
            throw LineItemFormatError.descriptionTooLong
        }

        self.description = description

        self.amount = amount

        if let sku = sku, sku.bytes.count > 128 {
            throw LineItemFormatError.skuTooLong
        }

        self.sku = sku
    }
}

/// Contains the information about what a given `KinPayment` was for.
public struct Invoice: Equatable {
    public enum InvoiceFormatError: String, Error {
        case atLeastOneLineItem = "Must have at least one LineItem"
        case tooManyLineItems = "Maximum of 1024 LineItem's allowed"
        case internalInconsistency = "Fail to generate invoice id"
    }

    public typealias Id = SHA224Hash

    /// Identifier for the `Invoice` that contains a SHA-224 of the `lineItems` data.
    public let id: Id

    /// 1-1024 `LineItem`s describing an itemized list of what the `Invoice` is for.
    public let lineItems: [LineItem]

    public var total: Kin {
        return lineItems.reduce(Kin(0)) { (subtotal, nextItem) -> Kin in
            return subtotal + nextItem.amount
        }
    }

    /// Validates `lineItems` and initializes an `Invoice` object.
    /// - Parameter lineItems: 1-1024 `LineItem`s describing an itemized list of what the `Invoice` is for.
    /// - Throws: `InvoiceFormatError`
    public init(lineItems: [LineItem]) throws {
        guard !lineItems.isEmpty else {
            throw InvoiceFormatError.atLeastOneLineItem
        }

        guard lineItems.count <= 1024 else {
            throw InvoiceFormatError.tooManyLineItems
        }

        self.lineItems = lineItems

        guard let invoiceData = lineItems.protoInvoice.data() else {
            throw InvoiceFormatError.internalInconsistency
        }

        self.id = SHA224Hash.of(bytes: [Byte](invoiceData))
    }
}

/// A collection of `Invoice`s. Often submitted in the same `KinTransaction` together.
public struct InvoiceList: Equatable {
    public enum InvoiceListFormatError: String, Error {
        case atLeastOneInvoice = "Must have at least one invoice"
        case tooManyInvoices = "Maximum of 100 invoices allowed"
        case internalInconsistency = "Fail to generate invoice list id"
    }

    public typealias Id = SHA224Hash

    /// Identifier for the `InvoiceList` that contains a SHA-224 of the `invoices` data.
    public let id: Id

    /// All the `Invoice`s in the list.
    public let invoices: [Invoice]

    /// Validates `invoices` and initializes a `InvoiceList` object.
    /// - Parameter invoices: all the `Invoice`s in the list
    /// - Throws: InvoiceListFormatError
    public init(invoices: [Invoice]) throws {
        guard !invoices.isEmpty else {
            throw InvoiceListFormatError.atLeastOneInvoice
        }

        guard invoices.count <= 100 else {
            throw InvoiceListFormatError.tooManyInvoices
        }

        self.invoices = invoices

        guard let invoiceListData = invoices.protoInvoiceList.data() else {
            throw InvoiceListFormatError.internalInconsistency
        }

        self.id = SHA224Hash.of(bytes: [Byte](invoiceListData))
    }
}
