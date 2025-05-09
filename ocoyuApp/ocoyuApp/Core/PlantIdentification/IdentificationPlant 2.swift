import SwiftUI
import PhotosUI


struct PlantIdentificationView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var isLoading: Bool = false
    @State private var showCamera: Bool = false // Estado para mostrar la cámara
    @State private var capturedImage: UIImage? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Identificar Planta")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding(.top)
                
                // Imagen seleccionada o capturada
                Group {
                    if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    } else if let capturedImage {
                        Image(uiImage: capturedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .overlay(
                                Text("Sin imagen seleccionada")
                                    .foregroundColor(.gray)
                                    .font(.headline)
                            )
                    }
                }
                .padding(.horizontal)
                
                // Botones para selección o captura de imagen
                HStack(spacing: 20) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("Seleccionar Imagen", systemImage: "photo")
                            .padding()
                            .background(Color.verde)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
                    
                    Button(action: {
                        showCamera = true
                    }) {
                        Label("Tomar Fotografía", systemImage: "camera")
                            .padding()
                            .background(Color.verde)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            //            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(isPresented: $showCamera) {
                ImagePicker2(image: $capturedImage)
            }
        }
    }
}
    
    

// Componente ImagePicker para capturar fotos
struct ImagePicker2: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker2

        init(parent: ImagePicker2) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct PlantIdentificationView_Previews: PreviewProvider {
    static var previews: some View {
        PlantIdentificationView()
    }
}


