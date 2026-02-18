// PersistenceController.swift
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "HabitFlowModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error: \(error)")
            }
        }
    }
    
    // Для превью
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        // Добавим тестовую привычку
        let habit = HabitCD(context: context)
        habit.id = UUID()
        habit.title = "Выпить воду"
        habit.createdAt = Date()
        habit.isCompleted = false
        habit.completedDates = []
        
        try? context.save()
        return controller
    }()
}
