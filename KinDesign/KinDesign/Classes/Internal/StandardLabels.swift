//
//  StandardLabels.swift
//  KinDesign
//
//  Created by Kik Interactive Inc.
//  Copyright © 2020 Kin Foundation. All rights reserved.
//

import UIKit

public class PrimaryLabel: UILabel {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        font = .systemFont(ofSize: 17, weight: .medium)
        textColor = .kinBlack
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

public class SecondaryLabel: UILabel {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        font = .systemFont(ofSize: 14, weight: .medium)
        textColor = .kinGray2
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
