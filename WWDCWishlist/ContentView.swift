//
//  ContentView.swift
//  WWDCWishlist
//
//  Created by Joshua Brunhuber on 16.06.23.
//

import SwiftUI

struct WishlistItem: Identifiable {
    let id = UUID()
    var name: String
    var description: String
}

@MainActor
class WishlistModel: ObservableObject {
    enum State {
        case loading
        case error
        case finished([WishlistItem])
    }
    
    @Published var state = State.loading
    
    func load() async {
        try? await Task.sleep(for: .seconds(2))
        state = .finished([
            WishlistItem(name: "CasePaths",
                         description: "CasePaths would it make super easy to access certain enum-cases just like KeyPaths."),
            WishlistItem(name: "MagicSign",
                         description: "Got a difficult codesigning problem? Let Xcode handle this with MagicSign powered by AI.")
        ])
    }
}

struct ContentView: View {
    @StateObject
    var wishlistModel = WishlistModel()
    
    var body: some View {
        NavigationStack {
            Group {
                switch wishlistModel.state {
                case .loading:
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                case .finished(let items):
                    List(items) { item in
                        NavigationLink(item.name, destination: EditView(wishlistItem: Binding(get: {
                            return item
                        }, set: { value, transaction in
                            var mutable = items
                            if let idx = mutable.firstIndex(where: {
                                $0.id == item.id
                            }) {
                                mutable[idx] = value
                            }
                            wishlistModel.state = .finished(mutable)
                        })))
                    }
                case .error:
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("Oh no.")
                    }
                }
            }
            .navigationTitle("WWDC Wishlist")
            .task {
                await wishlistModel.load()
            }
        }
    }
}

struct EditView: View {
    @Binding var wishlistItem: WishlistItem
    
    var body: some View {
        VStack {
            TextField("Name", text: $wishlistItem.name)
            TextField("Description", text: $wishlistItem.description, axis: .vertical)
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .navigationTitle("Edit Wishlist Item")
        .scenePadding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
