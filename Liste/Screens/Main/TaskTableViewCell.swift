//
//  TaskTableViewCell.swift
//  Liste
//
//  Created by Arash Nur Iman on 30/06/20.
//  Copyright © 2020 Apprendre. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var taskView: UIView!

    // MARK: Overrides
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
    }

}
