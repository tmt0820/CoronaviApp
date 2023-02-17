//
//  ViewController.swift
//  CoronaApp
//
//  Created by 三澤俊裕 on 2023/01/13.
//

import UIKit
import Charts

class PrefectureTotalViewController: UIViewController {
    
    var displayArray: [CovidInfo.Prefecture.Item] = []
    
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
        self.editData {
            DispatchQueue.main.async {
                self.setUpLayout()
            }
        }
    }
    
    private func editData(completion: () -> Void) {
        // 最新日付の都道府県別累計件数
        displayArray = CovidSingleton.shared.prefecture.itemList.filter {$0.date.contains(UserDefaults.standard.string(forKey: "latestDate")!)}
        
        displayArray.sort(by: {
            a, b -> Bool in
            return Int(a.npatients)! > Int(b.npatients)!
        })
        completion()
    }
    
    private func setUpLayout() {
        // NavigationBarの設定
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.textColor = .label
        label.text = "新型コロナ\n都道府県別累計感染者数"
        navigationItem.titleView = label
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        // NavigationBarの設定
        appearance.backgroundColor = .secondarySystemBackground
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
        
        let rightBarButton = UIBarButtonItem(title: "詳細へ", style: .done, target: self, action: #selector(tappedPrefectureButton))
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem?.tintColor = .label
        
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        // チャート設定
        chartViewAppear()
    }
    
    private func chartViewAppear() {
        
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
        for cnt in 0..<displayArray.count {
            names.append(self.displayArray[cnt].name_jp)
            entries.append(BarChartDataEntry(x: Double(cnt), y: Double(displayArray[cnt].npatients) ?? 0))
        }
        
        let chartData = BarChartDataSet(entries: entries, label: "コロナ感染者数")
        
        // 件数表示の色設定
        chartData.valueTextColor = .label
        chartData.valueFont = .boldSystemFont(ofSize: 10)
        
        barChartView.data = BarChartData(dataSet: chartData)
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: names)
        
    }
    
    @objc func tappedPrefectureButton() {
        let storyboard = UIStoryboard.init(name: "Prefecture", bundle: nil)
        let prefectureViewController = storyboard.instantiateViewController(withIdentifier: "PrefectureViewController") as! PrefectureViewController
        self.navigationController?.pushViewController(prefectureViewController, animated: true)
    }
}
