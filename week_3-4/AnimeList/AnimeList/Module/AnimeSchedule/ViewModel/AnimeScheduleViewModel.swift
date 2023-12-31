import Foundation
import RxSwift
import RxCocoa

class AnimeScheduleViewModel:BaseViewModel {
    static let shared = AnimeScheduleViewModel()
    
    let tabBarItem: [String] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Unknown", "Other"]
    
    let mondayAnime = BehaviorRelay<[AnimeEntity]>(value: [])
    let tuesdayAnime = BehaviorRelay<[AnimeEntity]>(value: [])
    let wednesdayAnime = BehaviorRelay<[AnimeEntity]>(value: [])
    let thursdayAnime = BehaviorRelay<[AnimeEntity]>(value: [])
    let fridayAnime = BehaviorRelay<[AnimeEntity]>(value: [])
    let unknownAnime = BehaviorRelay<[AnimeEntity]>(value: [])
    let otherAnime = BehaviorRelay<[AnimeEntity]>(value: [])
    
    func loadData <T: Codable>(for endpoint: Endpoint,with animeCalendar: AnimeCalendarEnum, resultType: T.Type){
        loadingState.accept(.loading)
        
        api.fetchRequest(endpoint: endpoint){ [weak self] (response: Result<T, Error>) in
            guard let self = self else { return }
            
            switch response{
            case .success(let data):
                if let data = data as? AnimeResponse {
                    self.responseData(data: data, with: animeCalendar)
                    self.loadingState.accept(.finished)
                    
                    if(data.data.isEmpty){
                        self.loadingState.accept(.empty)
                    }
                }
                break
            case .failure(let error):
                if let error = error as? CustomError {
                    self.errorMessage.accept(error.message)
                }
                self.loadingState.accept(.failed)
            }
        }
    }
    
    private func responseData(data: AnimeResponse, with animeCalendar: AnimeCalendarEnum){
        switch animeCalendar {
        case .monday:
            self.mondayAnime.accept(data.data)
            break
        case .tuesday:
            self.tuesdayAnime.accept(data.data)
            break
        case .wednesday:
            self.wednesdayAnime.accept(data.data)
            break
        case .thursday:
            self.thursdayAnime.accept(data.data)
            break
        case .friday:
            self.fridayAnime.accept(data.data)
            break
        case .unknown:
            self.unknownAnime.accept(data.data)
            break
        case .other:
            self.otherAnime.accept(data.data)
            break
        }
    }
}
