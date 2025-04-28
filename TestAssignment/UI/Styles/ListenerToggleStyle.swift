//
//  CheckmarkToggleStyle.swift
//  TestAssignment
//
//  Created by Artem Mihelson on 27.04.2025.
//


import SwiftUI

struct ListenerToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
            HStack {
                Rectangle()
                    
                    .foregroundColor(.white)
                    .frame(width: 120, height: 60, alignment: .center)
                    .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(.secondary, lineWidth: 1)
                            )
                    .overlay(
                        Circle()
                            .foregroundColor(.accentColor)
                            .padding(.all, 3)
                            .overlay(
                                Image(systemName: configuration.isOn ? "text.alignleft" : "headphones")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .font(Font.title.weight(.black))
                                    .frame(width: 24, height: 24, alignment: .center)
                                    .foregroundColor(.white)
                            )
                            .offset(x: configuration.isOn ? 28 : -28, y: 0)
                            .animation(Animation.linear(duration: 0.1), value: configuration.isOn)
                            
                    ).cornerRadius(30)
                    .overlay(
                        Circle()
                            .foregroundColor(.clear)
                            .padding(.all, 3)
                            .overlay(
                                Image(systemName: configuration.isOn ? "headphones" : "text.alignleft")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .font(Font.title.weight(.black))
                                    .frame(width: 24, height: 24, alignment: .center)
                                    .foregroundColor(.primary)
                            )
                            .offset(x: configuration.isOn ? -28 : 28, y: 0)
                            .animation(Animation.linear(duration: 0.1), value: configuration.isOn)
                            
                    ).cornerRadius(30)
                
                    .onTapGesture { configuration.isOn.toggle() }
            }
        }
}

struct CheckmarkToggleStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Toggle("Example Toggle", isOn: .constant(true))
                .toggleStyle(ListenerToggleStyle())
            
            Toggle("Example Toggle", isOn: .constant(false))
                .toggleStyle(ListenerToggleStyle())
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
