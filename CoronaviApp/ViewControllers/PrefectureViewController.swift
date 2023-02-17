//
//  DetailPrefuctureViewController.swift
//  CoronaApp
//
//  Created by 三澤俊裕 on 2023/01/17.
//

import UIKit
import Charts

class PrefectureViewController: UIViewController {
    
    var displayInfo: [CovidInfo.Prefecture.Item] = []
    
    lazy var barChartView: BarChartView = {
        let chartView = BarChartView()
        chartView.backgroundColor = .secondarySystemBackground
        chartView.noDataText = "データが存在しません。"
        // x軸の設定
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = .boldSystemFont(ofSize: 10)
        chartView.xAxis.labelTextColor = .label
        chartView.xAxis.drawGridLinesEnabled = false
        
        // y軸の設定
        let yAxis = chartView.leftAxis
        yAxis.labelTextColor = .label
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.axisMinimum = 0
        // y軸を非表示
        chartView.rightAxis.enabled = false
        
        // 凡例の設定
        chartView.legend.textColor = .label
        chartView.legend.font = .boldSystemFont(ofSize: 12)
        
        chartView.zoom(scaleX: 6, scaleY: 1, x: 0, y: 0)
        // ズーム不可
        chartView.setScaleEnabled(false)
        
        return chartView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        editData {
            setUpLayout()
        }
    }
    
    private func setUpLayout() {
        // ナビゲーションタイトル
        let selectDate = UserDefaults.standard.string(forKey: "selectedDate")!.suffix(5).replacingOccurrences(of: "-", with: "/")
        var month = selectDate.prefix(3)
        var day = selectDate.suffix(2)
        if month.first == "0" {
            month.removeFirst()
        }
        if day.first == "0" {
            day.removeFirst()
        }
        navigationItem.title = month + day + "感染状況"

        let rightBarButton = UIBarButtonItem(title: "過去推移", style: .done, target: self, action: #selector(tappedPastInfoButton))
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem?.tintColor = .label
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
        chartViewAppear()
    }
    
    @objc func tappedPastInfoButton() {
        let storyboard = UIStoryboard.init(name: "DetailPrefecture", bundle: nil)
        let detailPrefectureViewController = storyboard.instantiateViewController(withIdentifier: "DetailPrefectureViewController") as! DetailPrefectureViewController
        // push遷移
        self.navigationController?.pushViewController(detailPrefectureViewController, animated: true)
    }
    
    private func editData(completion: () -> Void) {
        // 最新日付の都道府県別累計件数
        let latestArray = CovidSingleton.shared.prefecture.itemList.filter {$0.date.contains(UserDefaults.standard.string(forKey: "selectedDate")!)}
        // 前日の都道府県別累計件数
        let oldArray = CovidSingleton.shared.prefecture.itemList.filter {$0.date.contains(UserDefaults.standard.string(forKey: "dayBefore")!)}
        
        displayInfo = latestArray
        for cnt in 0..<latestArray.count {
            displayInfo[cnt].npatients = ""
            displayInfo[cnt].npatients.append(String(Int(latestArray[cnt].npatients)! - Int(oldArray[cnt].npatients)!))
        }
        
        self.displayInfo.sort(by: {
            a, b -> Bool in
            return Int(a.npatients)! > Int(b.npatients)!
        })
        completion()
    }
    
    private func chartViewAppear() {
        // 棒グラフを表示
        view.addSubview(barChartView)
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        barChartView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 110).isActive = true
        barChartView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60).isActive = true
        barChartView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15).isActive = true
        barChartView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15).isActive = true

        // アニメーション設定
        barChartView.animate(yAxisDuration: 2.5)
        barChartView.animate(xAxisDuration: 2.5)
        setBarChartData()
    }
    
    private func setBarChartData() {
        var names: [String] = []
        var entries: [BarChartDataEntry] = []
        for cnt in 0..<displayInfo.count {
            names.append(self.displayInfo[cnt].name_jp)
            entries.append(BarChartDataEntry(x: Double(cnt), y: Double(displayInfo[cnt].npatients) ?? 0))
        }
        
        let chartData = BarChartDataSet(entries: entries, label: "コロナ感染者数")
        
        // 件数表示の色設定
        chartData.valueTextColor = .label
        chartData.valueFont = .boldSystemFont(ofSize: 10)
        
        barChartView.data = BarChartData(dataSet: chartData)
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: names)
    }
}
