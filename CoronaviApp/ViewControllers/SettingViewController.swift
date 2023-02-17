//
//  SettingViewController.swift
//  CoronaApp
//
//  Created by 三澤俊裕 on 2023/02/05.
//

import UIKit
import MessageUI

class SettingViewController: UIViewController {
    
    let menu = ["お知らせ", "利用規約", "プライバシーポリシー", "お問い合わせ"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "設定"
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
    }
    
    private func setupTableView() {
        let tableView = UITableView(frame: self.view.bounds, style: .grouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func popUpAlart(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "アプリについて"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        switch indexPath.row {
        case 0:
            cell.imageView?.image = UIImage(systemName: "newspaper")
            cell.textLabel?.text = menu[indexPath.row]
        case 1:
            cell.imageView?.image = UIImage(systemName: "doc.text.magnifyingglass")
            cell.textLabel?.text = menu[indexPath.row]
        case 2:
            cell.imageView?.image = UIImage(systemName: "personalhotspot.circle")
            cell.textLabel?.text = menu[indexPath.row]
        case 3:
            cell.imageView?.image = UIImage(systemName: "envelope.badge")
            cell.textLabel?.text = menu[indexPath.row]
        default: break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            popUpAlart(title: "お知らせ", message: "新しいお知らせはありません。")
            
        case 1:
            let storyboard = UIStoryboard.init(name: "TermsOfService", bundle: nil)
            let TermsOfServiceViewController = storyboard.instantiateViewController(withIdentifier: "TermsOfServiceViewController") as! TermsOfServiceViewController
            self.navigationController?.pushViewController(TermsOfServiceViewController, animated: true)
        case 2:
            let storyboard = UIStoryboard.init(name: "PrivacyPolicy", bundle: nil)
            let privacyPolicyViewController = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
            self.navigationController?.pushViewController(privacyPolicyViewController, animated: true)
        case 3:
            showMailComposer()
        default:
            break
        }
    }
    
    func showMailComposer() {
        guard MFMailComposeViewController.canSendMail() else {
            popUpAlart(title: "メールアカウント未設定", message: "メールアカウントが未設定の為ご利用出来ません。メールアカウントの設定を行なってから再度ご利用下さい。")
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["coronavi.info@gmail.com"])
        composer.setSubject("coronaviお問い合わせ")
        
        present(composer, animated: true)
    }
}

extension SettingViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true)
        switch result {
        case .cancelled:
            print("Cancelled")
        case .failed:
            popUpAlart(title: "メール", message: "メールの送信に失敗しました。")
        case .saved:
            popUpAlart(title: "メール", message: "メールを一時保存しました。")
        case .sent:
            popUpAlart(title: "メール", message: "メールの送信が完了しました。")
        default:
            popUpAlart(title: "メール", message: "予期しないエラーが発生しました。")
        }
    }
}
