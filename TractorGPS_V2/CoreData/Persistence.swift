//
//  Persistence.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 18/9/25.
//

import Foundation
import CoreData
import MapKit

struct SavedRecord: Identifiable {
    let id: UUID
    let date: Date
    let time: String
    let coverArea: String
    let avgSpeed: String
    let elevationGain: String
    let fieldName: String
    let coordinates: [CLLocationCoordinate2D]
}

final class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    private init() {
        let model = Self.makeModel()
        container = NSPersistentContainer(name: "FieldTracModel", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error {
                print("CoreData load error: \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let recordEntity = NSEntityDescription()
        recordEntity.name = "Record"
        recordEntity.managedObjectClassName = "NSManagedObject"

        var properties: [NSAttributeDescription] = []

        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false
        properties.append(idAttr)

        let dateAttr = NSAttributeDescription()
        dateAttr.name = "date"
        dateAttr.attributeType = .dateAttributeType
        dateAttr.isOptional = false
        properties.append(dateAttr)

        let timeAttr = NSAttributeDescription()
        timeAttr.name = "time"
        timeAttr.attributeType = .stringAttributeType
        timeAttr.isOptional = false
        properties.append(timeAttr)

        let coverAreaAttr = NSAttributeDescription()
        coverAreaAttr.name = "coverArea"
        coverAreaAttr.attributeType = .stringAttributeType
        coverAreaAttr.isOptional = false
        properties.append(coverAreaAttr)

        let avgSpeedAttr = NSAttributeDescription()
        avgSpeedAttr.name = "avgSpeed"
        avgSpeedAttr.attributeType = .stringAttributeType
        avgSpeedAttr.isOptional = false
        properties.append(avgSpeedAttr)

        let elevationGainAttr = NSAttributeDescription()
        elevationGainAttr.name = "elevationGain"
        elevationGainAttr.attributeType = .stringAttributeType
        elevationGainAttr.isOptional = false
        properties.append(elevationGainAttr)

        let fieldNameAttr = NSAttributeDescription()
        fieldNameAttr.name = "fieldName"
        fieldNameAttr.attributeType = .stringAttributeType
        fieldNameAttr.isOptional = true
        properties.append(fieldNameAttr)

        let coordsAttr = NSAttributeDescription()
        coordsAttr.name = "coordinates"
        coordsAttr.attributeType = .binaryDataAttributeType
        coordsAttr.isOptional = true
        properties.append(coordsAttr)

        recordEntity.properties = properties
        model.entities = [recordEntity]
        return model
    }

    func saveRecord(date: Date,
                    time: String,
                    coverArea: String,
                    avgSpeed: String,
                    elevationGain: String,
                    fieldName: String = "Field",
                    coordinates: [CLLocationCoordinate2D]) {
        let context = container.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Record", in: context)!
        let obj = NSManagedObject(entity: entity, insertInto: context)
        obj.setValue(UUID(), forKey: "id")
        obj.setValue(date, forKey: "date")
        obj.setValue(time, forKey: "time")
        obj.setValue(coverArea, forKey: "coverArea")
        obj.setValue(avgSpeed, forKey: "avgSpeed")
        obj.setValue(elevationGain, forKey: "elevationGain")
        obj.setValue(fieldName, forKey: "fieldName")
        obj.setValue(CoordinateHelper.encode(coordinates), forKey: "coordinates")

        do {
            try context.save()
        } catch {
            print("Failed to save record: \(error)")
        }
    }

    func fetchRecords() -> [SavedRecord] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Record")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            return try container.viewContext.fetch(request).compactMap { obj in
                let id = obj.value(forKey: "id") as? UUID ?? UUID()
                let date = obj.value(forKey: "date") as? Date ?? Date()
                let time = obj.value(forKey: "time") as? String ?? ""
                let cover = obj.value(forKey: "coverArea") as? String ?? ""
                let speed = obj.value(forKey: "avgSpeed") as? String ?? ""
                let ele = obj.value(forKey: "elevationGain") as? String ?? ""
                let name = obj.value(forKey: "fieldName") as? String ?? "Field"
                let coordsData = obj.value(forKey: "coordinates") as? Data ?? Data()
                let coords = CoordinateHelper.decode(coordsData)
                return SavedRecord(id: id, date: date, time: time, coverArea: cover, avgSpeed: speed, elevationGain: ele, fieldName: name, coordinates: coords)
            }
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }

    func deleteRecords(with ids: Set<UUID>) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Record")
        request.predicate = NSPredicate(format: "id IN %@", ids as NSSet)
        do {
            let items = try container.viewContext.fetch(request)
            items.forEach { container.viewContext.delete($0) }
            try container.viewContext.save()
        } catch {
            print("Delete error: \(error)")
        }
    }
}


