import UIKit


protocol TodayAnimeDelegate: AnyObject {
    func didTap(data: AnimeEntity)
}

class TodayAnime: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var currentAnimeCollection: UICollectionView!
    @IBOutlet weak var showButtonAll: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTableView()
    }
    
    weak var delegate: TodayAnimeDelegate?
    var currentAnime: [AnimeEntity] = []{
        didSet{
            currentAnimeCollection.reloadData()
        }
    }
}


extension TodayAnime: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func configureTableView(){
        currentAnimeCollection.delegate = self
        currentAnimeCollection.dataSource = self
        currentAnimeCollection.registerCellWithNib(TodayAnimeItem.self)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentAnime.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = currentAnime[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodayAnimeItem", for: indexPath) as! TodayAnimeItem
                
        cell.setUpComponent(title: data.title ?? "", date: "Ditayangkan pada pukul \(AnimeViewModel.shared.convertTime(from: data.broadcast?.time ?? "00:00", fromTimeZone: data.broadcast?.timezone ?? "Asia/Tokyo", to: "Asia/Jakarta" ) ?? "-")", urlImage: data.images?.jpg?.imageUrl ?? "", rating: data.score ?? 0.0 )
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 280, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = currentAnime[indexPath.row]

        delegate?.didTap(data: data)
    }
}