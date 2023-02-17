//
//  TermsOfServiceViewController.swift
//  CoronaApp
//
//  Created by 三澤俊裕 on 2023/02/11.
//

import UIKit
import PDFKit

class TermsOfServiceViewController: UIViewController {
    
    lazy var scrollview: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.frame = CGRect(x:0, y:0, width: view.frame.size.width, height: view.frame.size.height)
        scrollview.backgroundColor = .secondarySystemBackground
        scrollview.contentSize = CGSize(width: view.frame.size.width, height: view.frame.size.height)
        return scrollview
    }()
    
    lazy var serviceLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 15, y: 30, width: view.frame.size.width - 20, height: view.frame.size.height)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTerms()
    }
    
    private func setUpTerms() {
        navigationItem.title = "利用規約"
        
        self.view.addSubview(scrollview)
        guard let fileURL = Bundle.main.url(forResource: "service", withExtension: "txt"),
              let fileContents = try? String(contentsOf: fileURL, encoding: .utf8) else {
            fatalError("利用規約が読み込み出来ませんでした。")
        }
        serviceLabel.text = fileContents
        // text設定後の高さを調整
        serviceLabel.sizeToFit()
        scrollview.addSubview(serviceLabel)
        // スクロールビュー幅リサイズ
        scrollview.contentSize.height = serviceLabel.frame.size.height
    }
}
