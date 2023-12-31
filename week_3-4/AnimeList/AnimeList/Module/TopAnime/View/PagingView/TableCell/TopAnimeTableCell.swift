import UIKit
import Kingfisher

class TopAnimeTableCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var scoredByLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var episodeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlImage: UIImageView!
    @IBOutlet weak var rankView: UIView!
    @IBOutlet weak var rankLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    func configureUI(){
        cardView.roundCornersAll(radius: 10)
        rankView.roundCornersAll(radius: 3)
        urlImage.roundCornersAll(radius: 10)
    }
    
    func initialSetup(data: AnimeEntity, index: Int){
        scoredByLabel.text = (data.scoredBy ?? 0).formatAsDecimalString()
        if let score = data.score {
            scoreLabel.text = String(score)
        }
        episodeLabel.text = "\(data.type ?? "-") (\(data.episodes ?? 0) Episode)"
        titleLabel.text = data.title ?? "-"
        if let url = URL(string:data.images?.jpg?.imageUrl ?? ""){
            urlImage.kf.setImage(with: url, placeholder: UIImage(named: "ImagePlaceholder"))
        }
        rankLabel.text = "#\(index + 1)"
    }
}

