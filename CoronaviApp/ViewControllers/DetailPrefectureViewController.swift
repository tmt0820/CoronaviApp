//
//  DetailPrefuctureViewController.swift
//  CoronaApp
//
//  Created by 三澤俊裕 on 2023/01/17.
//

import UIKit
import Charts

class DetailPrefectureViewController: UIViewController {
    
    var displayInfo: [CovidInfo.Prefecture.Item] = []
    var displayDate: [String] = []
    var pickerView = UIPickerView()
    let prefectureList = ["北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県", "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県", "新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県", "静岡県", "愛知県", "三重県", "滋賀県", "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県", "鳥取県", "島根県", "岡山県", "広島県", "山口県", "徳島県", "香川県", "愛媛県", "高知県", "福岡県", "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"]
    
    // 折れ線グラフを生成
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .secondarySystemBackground
        chartView.xAxis.labelCount = displayDate.count
        // y軸の設定
        chartView.rightAxis.enabled = false
        let yAxis = chartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .label
        yAxis.axisLineColor = .white
        yAxis.axisMinimum = 0
        
        // x軸の設定
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        chartView.xAxis.setLabelCount(10, force: false)
        chartView.xAxis.labelTextColor = .label
        
        // 凡例の設定
        chartView.legend.textColor = .label
        chartView.legend.font = .boldSystemFont(ofSize: 12)
        
        chartView.zoom(scaleX: 6, scaleY: 1, x: 0, y: 0)
        
        return chartView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editData(prefectureText: UserDefaults.standard.string(forKey: "locationArea")!) {
            setUpLayout()
        }
    }
    
    private func editData(prefectureText text: String, completion: () -> Void) {
        // テキストボックスで入力されたデータの情報取得
        var prefectureInfo = CovidSingleton.shared.prefecture.itemList.filter {$0.name_jp.contains(text)}
        
        // 最初の１件目を除外
        var exPrefectureInfo = prefectureInfo
        exPrefectureInfo.removeFirst()
        // 最後の１件を除外
        prefectureInfo.removeLast()
        // 引き算する
        displayInfo = prefectureInfo
        for cnt in 0..<prefectureInfo.count {
            displayInfo[cnt].npatients = ""
            displayInfo[cnt].npatients.append(String(Int(prefectureInfo[cnt].npatients)! - Int(exPrefectureInfo[cnt].npatients)!))
        }
        completion()
    }
    
    private func chartViewAppear() {
        
        view.addSubview(lineChartView)
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        lineChartView.topAnchor.constraint(equalTo: pickerView.bottomAnchor).isActive = true
        lineChartView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60).isActive = true
        lineChartView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15).isActive = true
        lineChartView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15).isActive = true
        // アニメーション設定
        lineChartView.animate(xAxisDuration: 2.5)
        setLineChartData()
        
    }
    
    private func setLineChartData() {
        var entries: [ChartDataEntry] = []
        var date = ""
        var month = ""
        var day = ""
        for cnt in 0..<displayInfo.count {
            date = String(self.displayInfo[cnt].date.suffix(5)).replacingOccurrences(of: "-", with: "/")
            month = String(date.prefix(3))
            day = String(date.suffix(2))
            if month.first == "0" {
                month.removeFirst()
            }
            if day.first == "0" {
                day.removeFirst()
            }
            date = month + day
            displayDate.append(date)
            entries.append(contentsOf: [ChartDataEntry(x: Double(cnt), y: Double(displayInfo[cnt].npatients) ?? 0)])
        }
        
        let chartData = LineChartDataSet(entries: entries, label: "コロナ感染者数")
        
        // 件数表示の色設定
        chartData.valueTextColor = .label
        chartData.valueFont = .boldSystemFont(ofSize: 10)
        
        // 折れ線グラフの設定
        chartData.drawCirclesEnabled = false
        chartData.mode = .horizontalBezier
        chartData.lineWidth = 3
        chartData.fillAlpha = 0.8
        chartData.drawFilledEnabled = true
        chartData.drawHorizontalHighlightIndicatorEnabled = false
        
        let data = LineChartData(dataSet: chartData)
        data.setDrawValues(false)
        lineChartView.data = data
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: displayDate)
    }
    
    private func setUpLayout() {
        
        navigationItem.title = "過去の感染者推移"
        view.backgroundColor = .systemBackground
        // 検索バーを表示
        view.addSubview(pickerView)
        
        pickerView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:100)
        pickerView.layer.position = CGPoint(x: self.view.bounds.width/2, y: 130)
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(prefectureList.firstIndex(of: UserDefaults.standard.string(forKey: "locationArea")!)!, inComponent: 0, animated: true)
        chartViewAppear()
        
    }
}

extension DetailPrefectureViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return prefectureList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return prefectureList[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 配列の初期化
        displayInfo.removeAll()
        UserDefaults.standard.set(prefectureList[row], forKey: "locationArea")
        editData(prefectureText: UserDefaults.standard.string(forKey: "locationArea")!) {
            chartViewAppear()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
}
