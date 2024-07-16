//
//  Demo.swift
//  BiblioFi
//
//  Created by Nikunj Tyagi on 12/07/24.
//

//import SwiftUI
//
//struct Demo: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
//#Preview {
//    Demo() 
//}
import SwiftUI

struct Category {
    let name: String
    let imageName: String
}

struct Resource: Identifiable, Decodable {
    let id = UUID()
    let title: String
    let author: String
    let genre: String
}

struct Demo: View {
    @State private var searchText: String = ""
    @State private var showDropdown: Bool = false
    @State private var selectedCategory: Category? = nil
    
    let categories: [Category] = [
        Category(name: "Resource Title", imageName: "book.fill"),
        Category(name: "Author Name", imageName: "person.fill"),
        Category(name: "Genre", imageName: "tag.fill")
    ]
    
    @State private var resources: [Resource] = []
    
    var filteredResources: [Resource] {
        guard !searchText.isEmpty else { return resources }
        switch selectedCategory?.name {
        case "Resource Title":
            return resources.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        case "Author Name":
            return resources.filter { $0.author.lowercased().contains(searchText.lowercased()) }
        case "Genre":
            return resources.filter { $0.genre.lowercased().contains(searchText.lowercased()) }
        default:
            return resources
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search", text: $searchText, onEditingChanged: { isEditing in
                        self.showDropdown = isEditing
                    })
                    .foregroundColor(.black)
                }
                .padding()
                .background(Color(.white))
                .cornerRadius(8)
                .onTapGesture {
                    self.showDropdown = true
                }
                
                if !searchText.isEmpty {
                    Button(action: {
                        // Perform search action
                        self.showDropdown = false
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 8)
                }
            }
            .padding()
            
            if showDropdown {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(categories, id: \.name) { category in
                        Button(action: {
                            self.selectedCategory = category
                            self.searchText = "" // Clear searchText when category changes
                            self.showDropdown = false
                        }) {
                            HStack {
                                Image(systemName: category.imageName)
                                    .foregroundColor(.blue)
                                    .imageScale(.medium)
                                    .padding(.trailing, 4)
                                Text(category.name)
                                    .foregroundColor(.black)
                                    .padding(.vertical, 8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .background(Color(.white))
                .cornerRadius(8)
                .shadow(radius: 3)
                .padding(.horizontal)
            }
            
            List(filteredResources) { resource in
                VStack(alignment: .leading) {
                    Text(resource.title)
                        .font(.headline)
                    Text("by \(resource.author)")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            .listStyle(PlainListStyle())
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1).ignoresSafeArea())
        .onAppear {
            // Load sample data from JSON
            if let url = Bundle.main.url(forResource: "Resources", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    self.resources = try decoder.decode([Resource].self, from: data)
                } catch {
                    print("Error loading data: \(error)")
                }
            }
        }
    }
}

struct Demo_Previews: PreviewProvider {
    static var previews: some View {
        Demo()
    }
}
