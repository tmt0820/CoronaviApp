//
//  MenuViewController.swift
//  CoronaApp
//
//  Created by 三澤俊裕 on 2023/01/22.
//

import UIKit
import PKHUD
import CoreLocation

class MenuViewController: UIViewController {
    
    var dateInfo: [String] = []
    var locationManager: CLLocationManager!
    
    let menu = ["都道府県別感染者数(累計)", "都道府県別感染者数(日付を指定)", "都道府県別感染状況推移"]
    
    let datePicker: UIDatePicker = UIDatePicker()
    let dateFormatter: DateFormatter = DateFormatter()
    
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HUD.show(.progress, onView: view)
        view.backgroundColor = .systemBackground
        
        
        CovidAPI.getPrefecture { result, error in
            if let _ = error {
                DispatchQueue.main.async {
                    HUD.hide { _ in
                        self.displayApiAlart()
                    }
                }
                return
            }
            
            CovidSingleton.shared.prefecture = result
            self.editData()
            DispatchQueue.main.async {
                self.getLocaleInfo()
                self.setupNavigationBar()
                // tableViewの設定
                self.setupTableView()
                self.createDatePicker()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        HUD.hide()
        
    }
    
    func displayApiAlart() {
            let alert = UIAlertController(title:"通信エラー", message: "データの取得が出来ませんでした。\nしばらく経ってから再度ご利用下さい。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
    }
    
    @objc func onDidChangeDate(sender: UIDatePicker){
        // 指定日
        UserDefaults.standard.set(dateFormatter.string(from: sender.date), forKey: "selectedDate")
        // 指定日−1
        UserDefaults.standard.set(dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: sender.date)!), forKey: "dayBefore")
        
                let storyboard = UIStoryboard.init(name: "Prefecture", bundle: nil)
        let prefectureViewController = storyboard.instantiateViewController(withIdentifier: "PrefectureViewController") as! PrefectureViewController
        self.navigationController?.pushViewController(prefectureViewController, animated: true)
    }
    
    private func editData() {
        // 日付一覧取得
        let dataFlatMap = CovidSingleton.shared.prefecture.itemList.map { $0.date }
        // 重複データを除外
        dateInfo = Array(Set(dataFlatMap))
        // 日付降順
        dateInfo.sort(by: {
            a, b -> Bool in
            return a > b
        })
        UserDefaults.standard.set(dateInfo[0], forKey: "latestDate")
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "新型コロナウイルス感染状況"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .secondarySystemBackground
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
        
        // NavigationBarのタイトルの文字色の設定
        if traitCollection.userInterfaceStyle == .dark {
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        } else {
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        }
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let rightBarButton = UIBarButtonItem(image  : UIImage(systemName: "gearshape.fill"), style: .done, target: self, action: #selector(tappedSettingButton))
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem?.tintColor = .label
    }
    
    @objc func tappedSettingButton() {
        let storyboard = UIStoryboard.init(name: "Setting", bundle: nil)
        let SettingViewController = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        // push遷移
        self.navigationController?.pushViewController(SettingViewController, animated: true)
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: self.view.bounds, style: .grouped)
        tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func createDatePicker() {
        // datePickerを設定
        datePicker.frame = CGRect(x:30, y:200, width:self.view.frame.width, height:200)
        datePicker.layer.cornerRadius = 5.0
        datePicker.layer.shadowOpacity = 0.5
        // viewに表示させる設定
        datePicker.preferredDatePickerStyle = .inline
        datePicker.isHidden = true
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(onDidChangeDate(sender: )), for: .valueChanged)
        datePicker.locale = Locale(identifier: "ja-JP")
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        datePicker.minimumDate = dateFormatter.date(from: "2020-05-10")
        datePicker.maximumDate = dateFormatter.date(from: dateInfo[0])
        tableView.addSubview(datePicker)
        
        UserDefaults.standard.set(dateInfo[0], forKey: "selectedDate")
        UserDefaults.standard.set(dateInfo[1], forKey: "dayBefore")
    }
    
    private func getLocaleInfo() {
        // 現在の位置情報を取得
        locationManager = CLLocationManager()
        locationManager.delegate = self
        // ユーザーの使用許可を確認
        locationManager.requestWhenInUseAuthorization()
        // 位置情報の精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // アップデートする距離半径(m)
        locationManager.distanceFilter = 100
        // 位置情報の取得を開始
        locationManager.startUpdatingLocation()
        UserDefaults.standard.set("東京都", forKey: "locationErea")
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count + 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        switch indexPath.row {
        case 0:
            cell.imageView?.image = UIImage(systemName: "chart.bar.xaxis")
            cell.textLabel?.text = menu[indexPath.row]
        case 1:
            cell.imageView?.image = UIImage(systemName: "calendar")
            cell.textLabel?.text = menu[indexPath.row]
        case 3:
            cell.imageView?.image = UIImage(systemName: "chart.line.uptrend.xyaxis")
            cell.textLabel?.text = menu[2]
            
        default: break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 {
            let height: CGFloat = datePicker.isHidden ? 0.0 : 400.0
            return height
        } else {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dpIndexPath = NSIndexPath(row: 1, section: 0)
        if dpIndexPath as IndexPath == indexPath {
            datePicker.isHidden = !datePicker.isHidden
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.tableView?.beginUpdates()
                self.tableView?.deselectRow(at: indexPath, animated: true)
                self.tableView?.endUpdates()
            })
        } else if indexPath.row == 0 {
            let storyboard = UIStoryboard.init(name: "PrefectureTotal", bundle: nil)
            let prefectureTotalViewController = storyboard.instantiateViewController(withIdentifier: "PrefectureTotalViewController") as! PrefectureTotalViewController
            self.navigationController?.pushViewController(prefectureTotalViewController, animated: true)
            
        } else if indexPath.row == 3 {
            let storyboard = UIStoryboard.init(name: "DetailPrefecture", bundle: nil)
            let detailPrefectureViewController = storyboard.instantiateViewController(withIdentifier: "DetailPrefectureViewController") as! DetailPrefectureViewController
            self.navigationController?.pushViewController(detailPrefectureViewController, animated: true)
        }
    }
}

extension MenuViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            UserDefaults.standard.set("東京都", forKey: "locationArea")
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            let locate = CLLocation(latitude: (manager.location?.coordinate.latitude)!, longitude: (manager.location?.coordinate.longitude)!)
            CLGeocoder().reverseGeocodeLocation(locate) { placemarks, error in
                if let placemark = placemarks?.first?.administrativeArea {
                    UserDefaults.standard.set(placemark, forKey: "locationArea")
                }
            }
        default:
            break
        }
    }
}
