import UIKit
import RxSwift
import RxCocoa
import SkeletonView

class DetailMangaViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sourceButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGesture()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindData()
        loadData()
    }
    
    var malId: Int?
    private let disposeBag = DisposeBag()
    private let detailMangaVM = DetailMangaViewModel()
}

extension DetailMangaViewController {
    private func configureGesture(){
        backButton.rx.tap.subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
        favoriteButton.rx.tap.subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            self.navigationController?.popToRootViewController(animated: true)
        }).disposed(by: disposeBag)
        sourceButton.rx.tap.subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            self.navigationController?.popToRootViewController(animated: true)
        }).disposed(by: disposeBag)
    }
    
    private func bindData(){
        detailMangaVM.loadingState.subscribe(onNext: {[weak self] state in
            guard let self = self else { return }
            switch state {
            case .loading, .notLoad:
                self.tableView.reloadData()
                break
            case .failed:
                self.refreshPopUp(message: self.detailMangaVM.errorMessage.value)
                break
            case .finished:
                self.tableView.reloadData()
                break
            }
        }).disposed(by: disposeBag)
        
        detailMangaVM.loadingState2.subscribe(onNext: {[weak self] state in
            guard let self = self else { return }
            switch state {
            case .loading, .notLoad:
                self.tableView.reloadData()
                break
            case .failed:
                self.refreshPopUp(message: self.detailMangaVM.errorMessage.value)
                break
            case .finished:
                self.tableView.reloadData()
                break
            }
        }).disposed(by: disposeBag)
    }
    
    private func loadData(){
        if let malId = self.malId {
            detailMangaVM.loadData(for: Endpoint.getDetailManga(params:malId), resultType: DetailMangaResponse.self){title in
                
                self.detailMangaVM.loadData(for: Endpoint.getMangaMangadex(params: MangaParam(limit: 1, title: title)), resultType: MangaMangadexResponse.self){mangaId in
                    
                    self.detailMangaVM.loadData(for: Endpoint.getMangaChapters(params: MangaChaptersParam(orderChapter: "asc", mangaId: mangaId, translatedLanguage: "en")), resultType: MangaChaptersResponse.self)
                }
            }
        }
    }
    
    private func configureTableView (){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCellWithNib(MangaDetailInfoCell.self)
        tableView.registerCellWithNib(MangaChapterCell.self)
    }
    
    private func refreshPopUp(message: String){
        let vc = RefreshPopUp()
        vc.delegate = self
        vc.view.alpha = 0
        vc.errorLabel.text = message
        self.present(vc, animated: false, completion: nil)
        
        UIView.animate(withDuration: 0.5) {
            vc.view.alpha = 1
        }
    }
}

extension DetailMangaViewController: SkeletonTableViewDelegate, UITableViewDataSource {
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 2
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        switch indexPath.section {
        case 0:
            return String(describing: MangaDetailInfoCell.self)
        case 1:
            return String(describing: MangaChapterCell.self)
        default:
            return String(describing: UITableViewCell.self)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as MangaDetailInfoCell
            if(detailMangaVM.loadingState.value == StateLoading.finished){
                cell.hideSkeleton()
            }else{
                cell.showAnimatedGradientSkeleton()
            }
            cell.selectionStyle = .none
            if let detailManga = self.detailMangaVM.mangaDetail.value{
                cell.initialSetup(data: detailManga)
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as MangaChapterCell
            if(detailMangaVM.loadingState.value == StateLoading.finished){
                cell.hideSkeleton()
            }else{
                cell.showAnimatedGradientSkeleton()
            }
            cell.mangaChapters = detailMangaVM.mangaChapters.value
            cell.viewHeight.constant = CGFloat((detailMangaVM.mangaChapters.value.count * 76) + 59)
            cell.selectionStyle = .none
            switch detailMangaVM.order.value {
            case true:
                cell.sortButton.setImage(UIImage(systemName: "arrow.down"), for: .normal)
            case false:
                cell.sortButton.setImage(UIImage(systemName: "arrow.up"), for: .normal)
            }
            cell.delegate = self
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension DetailMangaViewController: RefreshPopUpDelegate, MangaChapterCellDelegate {
    func didTapSortChapter() {
        detailMangaVM.changeOrder(state: detailMangaVM.order.value)
        tableView.reloadData()
    }
    
    func didTapNavigateReadChapter(chapterId: String) {
        let vc = ReadMangaViewController()
        vc.chapterId = chapterId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapRefresh() {
        loadData()
        self.dismiss(animated: false)
    }
}
