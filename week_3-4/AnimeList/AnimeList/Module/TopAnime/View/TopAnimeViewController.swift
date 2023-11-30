import UIKit
import RxSwift
import RxCocoa
import Parchment

class TopAnimeViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var appBar: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPagingVC()
        buttonGesture()
    }

    private let disposeBag = DisposeBag()
    private let topAnimeVM = TopAnimeViewModel()
}

extension TopAnimeViewController: PagingViewControllerDataSource, PagingViewControllerDelegate {
    
    func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
        return topAnimeVM.tabBarItem.count
    }
    
    func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        let vc = TopAnimePagingView(index: index)
        return vc
    }
    
    func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        let data = topAnimeVM.tabBarItem[index]
        return PagingIndexItem(index: index, title: data)
    }
}

extension TopAnimeViewController {
    func setUpPagingVC() {
        let pagingVC = PagingViewController(viewControllers: [TopAnimePagingView(index: 0), TopAnimePagingView(index: 1), TopAnimePagingView(index: 2), TopAnimePagingView(index: 3)])
        pagingVC.configure(parent: self, nslayoutTopAnchor: appBar.bottomAnchor)
    }
    func buttonGesture() {
        backButton.rx.tap.subscribe(onNext: {_ in self.navigationController?.popToRootViewController(animated: true)
        }
        ).disposed(by: disposeBag)
    }
}