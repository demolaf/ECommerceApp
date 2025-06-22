//
//  FetchedResultsControllerObserver.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//

import RxSwift
import CoreData

nonisolated class FetchedResultsControllerObserver<T: NSFetchRequestResult>: NSObject, NSFetchedResultsControllerDelegate {
    private let subject: BehaviorSubject<[T]>
    private let frc: NSFetchedResultsController<T>

    init(fetchRequest: NSFetchRequest<T>, context: NSManagedObjectContext) throws {
        frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        subject = BehaviorSubject<[T]>(value: [])

        super.init()

        frc.delegate = self
        try frc.performFetch()
        subject.onNext(frc.fetchedObjects ?? [])
    }

    func asObservable() -> Observable<[T]> {
        return subject.asObservable()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let objects = controller.fetchedObjects as? [T] else { return }
        subject.onNext(objects)
    }

    deinit {
        subject.onCompleted()
    }
}
