import SwiftUI

struct SideMenu: View {
    @State private var selectedMenuItem: String? = "Profile"
    
    var body: some View {
        VStack(alignment: .leading) {
            // User Info Section
            HStack {
                Image(systemName: "person")
                    .padding(12)
                    .background(Color.white.opacity(0.2))
                    .mask(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Meng To")
                        .font(.body)
                    
                    Text("UI Designer")
                        .font(.subheadline)
                        .opacity(0.7)
                }
                Spacer()
            }
            .padding()
            
            // Menu Items
            MenuItem(icon: "person.fill", text: "Profile", isSelected: selectedMenuItem == "Profile")
                .onTapGesture {
                    selectedMenuItem = "Profile"
                }
            
            MenuItem(icon: "star.fill", text: "Premium", isSelected: selectedMenuItem == "Premium")
                .onTapGesture {
                    selectedMenuItem = "Premium"
                }
            
            MenuItem(icon: "clock.fill", text: "History", isSelected: selectedMenuItem == "History")
                .onTapGesture {
                    selectedMenuItem = "History"
                }
            
            MenuItem(icon: "gearshape.fill", text: "Settings", isSelected: selectedMenuItem == "Settings")
                .onTapGesture {
                    selectedMenuItem = "Settings"
                }
            
            Spacer()
            
            // Logout Button
            MenuItem(icon: "arrow.backward.square.fill", text: "Logout", isSelected: selectedMenuItem == "Logout")
                .onTapGesture {
                    selectedMenuItem = "Logout"
                }
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundColor(.white)
        .frame(maxWidth: 288, maxHeight: .infinity)
        .background(Color(hex: "17203A"))
        .mask(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MenuItem: View {
    var icon: String
    var text: String
    var isSelected: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isSelected ? .blue : .white)
                .frame(width: 24, height: 24)
            
            Text(text)
                .foregroundColor(isSelected ? .blue : .white)
                .fontWeight(isSelected ? .bold : .regular)
            
            Spacer()
        }
        .padding()
        .background(isSelected ? Color.white.opacity(0.1) : Color.clear)
        .cornerRadius(10)
    }
}

struct SideMenu_Previews: PreviewProvider {
    static var previews: some View {
        SideMenu()
    }
}

