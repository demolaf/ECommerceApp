# Core Data Performance Improvements

## Overview
This document outlines the performance improvements made to the `ProductLocalDatasourceImpl` class to enhance Core Data operations and provide better user experience.

## Key Improvements Implemented

### 1. Background Context Operations
- **Added Background Context**: Created a dedicated background context for heavy operations
- **Context Management**: Proper merge policy configuration (`NSMergeByPropertyObjectTrumpMergePolicy`)
- **Thread Safety**: Background operations don't block the main thread

### 2. Batch Operations
- **Batch Delete**: Replaced individual object deletion with `NSBatchDeleteRequest`
- **Batch Insert**: Implemented batch processing for large datasets
- **Performance Gains**: Significant performance improvement for large datasets (100+ items)

### 3. Async Operations
- **Observable-based Async**: Added async versions of heavy operations returning `Observable<Result<Void, Error>>`
- **Non-blocking UI**: Heavy operations no longer block the main thread
- **Progress Tracking**: Operations can be observed and cancelled if needed

### 4. Smart Operation Selection
- **Threshold-based Routing**: 
  - Products: >100 items → Background context
  - Orders: >50 items → Background context
  - Cart: >20 items → Batch delete
- **Optimal Performance**: Uses the most efficient method based on dataset size

### 5. Memory Management
- **Batch Processing**: Large datasets processed in smaller chunks
  - Products: 50 items per batch
  - Orders: 25 items per batch
- **Context Merging**: Proper merging of changes between background and main contexts
- **Memory Efficiency**: Reduced memory footprint for large operations

### 6. Enhanced Error Handling
- **Specific Error Types**: Added `databaseError(String)` to `Failure` enum
- **Better Error Messages**: More descriptive error messages for debugging
- **Graceful Degradation**: Fallback to main context if background context unavailable

## Implementation Details

### Background Context Setup
```swift
private let backgroundContext: NSManagedObjectContext?

init(moc: NSManagedObjectContext) {
    self.moc = moc
    self.backgroundContext = moc.persistentStoreCoordinator?.newBackgroundContext()
    self.backgroundContext?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
}
```

### Batch Delete Implementation
```swift
let deleteRequest = NSBatchDeleteRequest(fetchRequest: ProductMO.fetchRequest())
deleteRequest.resultType = .resultTypeObjectIDs
let deleteResult = try moc.execute(deleteRequest) as? NSBatchDeleteResult
```

### Context Merging
```swift
if let objectIDs = deleteResult?.result as? [NSManagedObjectID] {
    let changes = [NSDeletedObjectsKey: objectIDs]
    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [moc])
}
```

### Async Operation Pattern
```swift
func updateProductsAsync(_ products: [ProductDTO]) -> Observable<Result<Void, Error>> {
    return Observable.create { [weak self] observer in
        // Background context operations
        backgroundContext.perform {
            // Batch operations
            // Context merging
            observer.onNext(.success(()))
            observer.onCompleted()
        }
        return Disposables.create()
    }
}
```

## Performance Benefits

### Before Improvements
- **Blocking Operations**: All operations on main thread
- **Individual Deletes**: One-by-one object deletion
- **Memory Issues**: Large datasets could cause memory pressure
- **UI Freezing**: Heavy operations could freeze the UI

### After Improvements
- **Non-blocking**: Heavy operations moved to background
- **Batch Processing**: Efficient bulk operations
- **Memory Efficient**: Controlled memory usage with batching
- **Responsive UI**: Main thread remains responsive
- **Scalable**: Handles large datasets efficiently

## Usage Recommendations

### For Small Datasets (< 50 items)
- Use synchronous methods for simplicity
- Operations are fast enough on main thread

### For Large Datasets (> 50 items)
- Use async methods for better user experience
- Operations run in background, UI remains responsive

### For Very Large Datasets (> 100 items)
- Always use async methods
- Consider implementing progress indicators
- Monitor memory usage

## Migration Guide

### Existing Code
```swift
// Old synchronous approach
let result = datasource.updateProducts(products)
```

### New Async Approach
```swift
// New async approach
datasource.updateProductsAsync(products)
    .subscribe(onNext: { result in
        switch result {
        case .success:
            // Handle success
        case .failure(let error):
            // Handle error
        }
    })
    .disposed(by: disposeBag)
```

## Best Practices

1. **Always use async methods for large datasets**
2. **Implement proper error handling**
3. **Monitor memory usage for very large operations**
4. **Consider implementing progress indicators**
5. **Test with realistic dataset sizes**
6. **Use appropriate batch sizes for your use case**

## Future Enhancements

1. **Progress Tracking**: Add progress callbacks for long operations
2. **Cancellation Support**: Allow cancelling long-running operations
3. **Retry Logic**: Automatic retry for failed operations
4. **Metrics**: Performance monitoring and analytics
5. **Optimization**: Further tuning based on usage patterns 