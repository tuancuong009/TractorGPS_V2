//
//  HistoryItem.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 18/9/25.
//

import SwiftUI

struct HistoryView: View {
    
    @Binding var isStart: Bool
    @Environment(\.safeAreaInsets) var safeInsets
    @State private var historyItems: [SavedRecord] = []
    
    @State private var isSelectionMode = false
    @State private var selectedItems: Set<UUID> = []
    @State private var showDeleteAlert = false
    
    // For navigation
    @State private var selectedRecord: SavedRecord?
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                // Header
                HStack {
                    Text("History")
                        .font(AppFonts.bold(size: 34))
                    Spacer()
                    if historyItems.count > 0 {
                        Button(action: {
                            if isSelectionMode {
                                isSelectionMode = false
                                selectedItems.removeAll()
                                isStart = false
                            } else {
                                isSelectionMode = true
                            }
                        }) {
                            Text(isSelectionMode ? "Cancel" : "Select")
                                .font(AppFonts.regular(size: 15))
                                .foregroundColor(isSelectionMode ? .red : AppTheme.primary )
                               
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Empty state
                if historyItems.isEmpty {
                    VStack(alignment: .center, spacing: 5) {
                        Image("no_history")
                            .padding(.bottom, 20)
                        Text("No History")
                            .font(AppFonts.semiBold(size: 24))
                        Text("No records added yet.")
                            .font(AppFonts.regular(size: 17))
                            .foregroundColor(Color.init(hex: "8E8E93"))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(historyItems) { item in
                                HStack(spacing: 12) {
                                    // Checkbox khi selection mode
                                    if isSelectionMode {
                                        Button(action: {
                                            toggleSelection(for: item)
                                        }) {
                                            Image(systemName: selectedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(selectedItems.contains(item.id) ? .blue : .gray)
                                                .font(.title2)
                                                .scaleEffect(selectedItems.contains(item.id) ? 1.2 : 1.0)
                                                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: selectedItems)
                                        }
                                    }
                                    
                                    // Content area
                                    HStack(spacing: 10){
                                        VStack{
                                            Text(item.coverArea.replacingOccurrences(of: " ha", with: "")).font(AppFonts.bold(size: 20)).foregroundColor(AppTheme.primary)
                                            Text("Ha").font(AppFonts.medium(size: 12)).foregroundColor(Color.black.opacity(0.6))
                                        }
                                        .frame(width: 70, height: 70)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 2) {
                                                Text("Farming Type:")
                                                    .frame(width: 90, alignment: .leading)
                                                    .font(AppFonts.regular(size: 12)).opacity(0.6)
                                                
                                                Text(item.fieldName)
                                                    .font(AppFonts.regular(size: 12))
                                            }
                                            HStack(spacing: 2) {
                                                Text("Date:")
                                                    .frame(width: 90, alignment: .leading)
                                                    .font(AppFonts.regular(size: 12)).opacity(0.6)
                                                
                                                Text(item.date.formatted(date: .abbreviated, time: .omitted))
                                                    .font(AppFonts.regular(size: 12))
                                            }
                                            HStack(spacing: 2) {
                                                Text("Time:")
                                                    .frame(width: 90, alignment: .leading)
                                                    .font(AppFonts.regular(size: 12)).opacity(0.6)
                                                
                                                Text(item.time)
                                                    .font(AppFonts.medium(size: 13))
                                            }
                                        }
                                        Spacer()
                                        
                                        if !isSelectionMode {
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(AppTheme.textTertiary)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        ZStack {
                                            // Highlight khi selected
                                            if selectedItems.contains(item.id) {
                                                Color.blue.opacity(0.1)
                                                    .cornerRadius(12)
                                                    .transition(.opacity)
                                            }
                                            AppTheme.backgroundTertiary
                                        }
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Color.init(hex: "1C1C1C").opacity(0.1), lineWidth: 1)
                                    )
                                    .cornerRadius(12)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if isSelectionMode {
                                            toggleSelection(for: item)
                                        } else {
                                            selectedRecord = item
                                        }
                                    }
                                  
                                    .scaleEffect(selectedItems.contains(item.id) ? 0.97 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedItems)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 8)
                    }
                    
                    // Delete button
                    if !selectedItems.isEmpty {
                        Button(action: {
                            showDeleteAlert = true
                        }) {
                            Text("Delete")
                                .font(AppFonts.regular(size: 17))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.init(hex: "FF3B30").opacity(0.16))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut, value: selectedItems)
                    }
                }
            }
            
            .navigationDestination(isPresented: Binding(
                get: { selectedRecord != nil },
                set: { isActive in
                    if !isActive { selectedRecord = nil }
                }
            )) {
                if let record = selectedRecord {
                    RecordDetailView(record: record)
                }
            }
            .navigationBarHidden(true)
            .onChange(of: selectedItems.count) { count in
                isStart = count > 0
            }
            .padding(.bottom, !isStart ? safeInsets.bottom + 70 : 0)
            .onAppear {
                historyItems = PersistenceController.shared.fetchRecords()
            }
            .alert("Delete History", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteSelectedItems()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete these records? This action can not be undo")
            }
        }
    }
    
    private func toggleSelection(for item: SavedRecord) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
    }
    
    private func deleteSelectedItems() {
        let ids = Set(selectedItems)
        PersistenceController.shared.deleteRecords(with: ids)
        historyItems.removeAll { ids.contains($0.id) }
        selectedItems.removeAll()
        isSelectionMode = false
        isStart = false
    }
}
