import UIKit
import DGCharts
import RxSwift
import RxCocoa

protocol ProfileStatsCellDelegate: AnyObject {
    func didTapTab(state: Bool)
}

class ProfileStatsCell: UITableViewCell {
     
    @IBOutlet weak var averageTitleLabel: UILabel!
    @IBOutlet weak var droppedLabel: UILabel!
    @IBOutlet weak var droppedTitleLabel: UILabel!
    @IBOutlet weak var onHoldTitleLabel: UILabel!
    @IBOutlet weak var completeLabel: UILabel!
    @IBOutlet weak var completeTitleLabel: UILabel!
    @IBOutlet weak var onHoldLabel: UILabel!
    @IBOutlet weak var mangaStatsLabel: UILabel!
    @IBOutlet weak var animeStatsLabel: UILabel!
    @IBOutlet weak var planToWatchLabel: UILabel!
    @IBOutlet weak var watchLabel: UILabel!
    @IBOutlet weak var episodeLabel: UILabel!
    @IBOutlet weak var showLabel: UILabel!
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var planToWatchTitleLabel: UILabel!
    @IBOutlet weak var watchingTitleLabel: UILabel!
    @IBOutlet weak var episodeTitleLabel: UILabel!
    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var profileStatsView: UIView!
    @IBOutlet weak var mangaStatsTab: UIView!
    @IBOutlet weak var animeStatsTab: UIView!
    @IBOutlet weak var pieChart: PieChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
        configureGesture()
    }
    
    private let disposeBag = DisposeBag()
    weak var delegate: ProfileStatsCellDelegate?
}

extension ProfileStatsCell {
    func configureUI(){
        profileStatsView.roundCornersAll(radius: 8)
        onHoldTitleLabel.text = .localized("onHold")
        completeTitleLabel.text = .localized("completed")
        droppedTitleLabel.text = .localized("dropped")
        animeStatsLabel.text = .localized("animeStats")
        mangaStatsLabel.text = .localized("mangaStats")
        averageTitleLabel.text = .localized("averageRating")
    }
    
    func initialSetup(tabBarState: Bool, userStats: UserStatsEntity){
        let customFontBold = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        let customFontMedium = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
        
        switch tabBarState {
        case true:
            animeStatsTab.backgroundColor = UIColor(named: "SecondaryBackgroundColor")
            mangaStatsTab.backgroundColor = UIColor.white
            showTitleLabel.text = .localized("titles")
            episodeTitleLabel.text = "Chapters"
            watchingTitleLabel.text = .localized("reading")
            planToWatchTitleLabel.text = .localized("planToRead")
            
            setPieChartData(data: userStats.manga)
            
            if let boldFont = customFontBold, let mediumFont = customFontMedium {
                mangaStatsLabel.font = boldFont
                animeStatsLabel.font = mediumFont
                animeStatsLabel.textColor = UIColor.darkGray
                mangaStatsLabel.textColor = UIColor.black
            }
        case false:
            animeStatsTab.backgroundColor = UIColor.white
            mangaStatsTab.backgroundColor = UIColor(named: "SecondaryBackgroundColor")
            showTitleLabel.text = .localized("shows")
            watchingTitleLabel.text = .localized("watching")
            episodeTitleLabel.text = "Episodes"
            planToWatchTitleLabel.text = .localized("planToWatch")
            
            setPieChartData(data: userStats.anime)
            
            if let boldFont = customFontBold, let mediumFont = customFontMedium {
                mangaStatsLabel.font = mediumFont
                animeStatsLabel.font = boldFont
                animeStatsLabel.textColor = UIColor.black
                mangaStatsLabel.textColor = UIColor.darkGray
            }
        }
    }
    
    func configureGesture(){
        mangaStatsTab.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.didTapTab(state: true)
            }).disposed(by: disposeBag)
        
        animeStatsTab.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.didTapTab(state: false)
            }).disposed(by: disposeBag)
    }
    
    func setPieChartData(data: UserStatsEntityItem) {
        
        averageRatingLabel.text = String(data.averageRating)
        showLabel.text = data.shows.formatAsDecimalString()
        episodeLabel.text = data.episodes.formatAsDecimalString()
        watchLabel.text = data.watching.formatAsDecimalString()
        completeLabel.text = data.completed.formatAsDecimalString()
        onHoldLabel.text = data.onHold.formatAsDecimalString()
        droppedLabel.text = data.drop.formatAsDecimalString()
        planToWatchLabel.text = data.planToWatch.formatAsDecimalString()
        
        let entries = [
            PieChartDataEntry(value: Double(data.watching), label: "Watching"),
            PieChartDataEntry(value: Double(data.completed), label: "Completed"),
            PieChartDataEntry(value: Double(data.onHold), label: "On-Hold"),
            PieChartDataEntry(value: Double(data.drop), label: "Dropped"),
            PieChartDataEntry(value: Double(data.planToWatch), label: "Plan-to-Watch")
        ]
        
        let total = entries.reduce(0) { $0 + $1.value }
        
        let percentageEntries = entries.map { entry in
            let percentage = (entry.value / total) * 100
            return PieChartDataEntry(value: percentage, label: entry.label)
        }
        
        let colors: [UIColor] = [
            UIColor.systemGreen,
            UIColor.systemBlue,
            UIColor.systemOrange,
            UIColor.systemRed,
            UIColor.systemBrown
        ]
        
        let dataSet = PieChartDataSet(entries: percentageEntries)
        dataSet.colors = colors
        dataSet.drawValuesEnabled = false
        
        let data = PieChartData(dataSet: dataSet)
        
        pieChart.data = data
        pieChart.legend.enabled = false
        pieChart.drawEntryLabelsEnabled = false
        pieChart.highlightPerTapEnabled = false
        
        pieChart.animate(xAxisDuration: 1.5, easingOption: .easeInOutBack)
        
    }
}
