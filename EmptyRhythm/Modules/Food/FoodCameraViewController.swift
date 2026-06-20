import UIKit
import Vision
import AVFoundation

// MARK: - 拍照识餐（Vision + 候选确认）
class FoodCameraViewController: UIViewController {

    var onFoodSelected: ((FoodItem, Double, MealType) -> Void)?

    private let imageView = UIImageView()
    private let captureButton = UIButton(type: .system)
    private let analyzeButton = UIButton(type: .system)
    private let resultCard = UIView()
    private let resultTitle = UILabel()
    private let candidateTable = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let disclaimerLabel = UILabel()

    private var capturedImage: UIImage?
    private var candidates: [FoodItem] = []
    private var selectedMealType: MealType = .lunch

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L("camera.title")
        view.setPageBackground()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: L("common.cancel"), style: .plain, target: self, action: #selector(dismiss_)
        )
        setupUI()
        checkCameraPermission()
    }

    private func setupUI() {
        // Image preview
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = AppColor.bgSecondary
        imageView.layer.cornerRadius = AppUIStyle.radiusLarge
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        // Placeholder
        let placeholder = UIImageView(image: UIImage(systemName: "camera.fill"))
        placeholder.tintColor = AppColor.disabledGray
        placeholder.contentMode = .scaleAspectFit
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(placeholder)

        // Capture button
        captureButton.setTitle(L("camera.take_photo"), for: .normal)
        captureButton.setMainStyle()
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        view.addSubview(captureButton)

        // Analyze button
        analyzeButton.setTitle(L("camera.analyze"), for: .normal)
        analyzeButton.setAIStyle()
        analyzeButton.translatesAutoresizingMaskIntoConstraints = false
        analyzeButton.addTarget(self, action: #selector(analyzeImage), for: .touchUpInside)
        analyzeButton.isHidden = true
        view.addSubview(analyzeButton)

        // Result card
        resultCard.setCardStyle()
        resultCard.isHidden = true
        resultCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultCard)

        resultTitle.setSubTitleStyle()
        resultTitle.text = L("camera.candidates")
        resultTitle.translatesAutoresizingMaskIntoConstraints = false
        resultCard.addSubview(resultTitle)

        candidateTable.register(FoodSearchCell.self, forCellReuseIdentifier: FoodSearchCell.reuseID)
        candidateTable.delegate = self
        candidateTable.dataSource = self
        candidateTable.rowHeight = 72
        candidateTable.backgroundColor = .clear
        candidateTable.translatesAutoresizingMaskIntoConstraints = false
        resultCard.addSubview(candidateTable)

        // Activity indicator
        activityIndicator.color = AppColor.mainTint
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)

        // Disclaimer
        disclaimerLabel.text = L("camera.disclaimer")
        disclaimerLabel.setCaptionStyle()
        disclaimerLabel.textAlignment = .center
        disclaimerLabel.numberOfLines = 0
        disclaimerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(disclaimerLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: AppUIStyle.paddingM),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppUIStyle.paddingM),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppUIStyle.paddingM),
            imageView.heightAnchor.constraint(equalToConstant: 220),

            placeholder.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            placeholder.widthAnchor.constraint(equalToConstant: 60),
            placeholder.heightAnchor.constraint(equalToConstant: 60),

            captureButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: AppUIStyle.paddingM),
            captureButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppUIStyle.paddingM),
            captureButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppUIStyle.paddingM),
            captureButton.heightAnchor.constraint(equalToConstant: 50),

            analyzeButton.topAnchor.constraint(equalTo: captureButton.bottomAnchor, constant: AppUIStyle.paddingS),
            analyzeButton.leadingAnchor.constraint(equalTo: captureButton.leadingAnchor),
            analyzeButton.trailingAnchor.constraint(equalTo: captureButton.trailingAnchor),
            analyzeButton.heightAnchor.constraint(equalToConstant: 50),

            resultCard.topAnchor.constraint(equalTo: analyzeButton.bottomAnchor, constant: AppUIStyle.paddingM),
            resultCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppUIStyle.paddingM),
            resultCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppUIStyle.paddingM),
            resultCard.heightAnchor.constraint(equalToConstant: 280),

            resultTitle.topAnchor.constraint(equalTo: resultCard.topAnchor, constant: AppUIStyle.paddingM),
            resultTitle.leadingAnchor.constraint(equalTo: resultCard.leadingAnchor, constant: AppUIStyle.paddingM),

            candidateTable.topAnchor.constraint(equalTo: resultTitle.bottomAnchor, constant: 8),
            candidateTable.leadingAnchor.constraint(equalTo: resultCard.leadingAnchor),
            candidateTable.trailingAnchor.constraint(equalTo: resultCard.trailingAnchor),
            candidateTable.bottomAnchor.constraint(equalTo: resultCard.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            disclaimerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            disclaimerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            disclaimerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
    }

    // MARK: - Camera Permission
    private func checkCameraPermission() {
        // Permission is requested only when user taps the button (5.1.1 compliance)
    }

    @objc private func takePhoto() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showPhotoLibrary()
            return
        }
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            presentCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted { self?.presentCamera() }
                    // If denied: show informational alert only (no settings redirect per 5.1.1)
                    else { self?.showCameraUnavailable() }
                }
            }
        case .denied, .restricted:
            showCameraUnavailable()
        @unknown default:
            break
        }
    }

    private func presentCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }

    private func showPhotoLibrary() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    private func showCameraUnavailable() {
        let alert = UIAlertController(
            title: L("camera.unavailable.title"),
            message: L("camera.unavailable.message"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L("common.ok"), style: .default))
        present(alert, animated: true)
    }

    // MARK: - Vision Analysis
    @objc private func analyzeImage() {
        guard let image = capturedImage, let cgImage = image.cgImage else { return }
        activityIndicator.startAnimating()
        analyzeButton.isEnabled = false
        resultCard.isHidden = true

        DispatchQueue.global(qos: .userInitiated).async {
            let request = VNClassifyImageRequest { [weak self] request, _ in
                guard let self = self else { return }
                let observations = (request.results as? [VNClassificationObservation]) ?? []

                // 只取置信度 > 0.1 的标签，避免低置信度误导
                let topObs = observations.filter { $0.confidence > 0.1 }.prefix(8)

                var candidates: [FoodItem] = []
                var matchedLabels: [String] = []

                for obs in topObs {
                    let label = obs.identifier.lowercased()
                    let matches = VisionFoodMapper.match(label: label, confidence: obs.confidence)
                    for m in matches {
                        if !candidates.contains(where: { $0.id == m.id }) {
                            candidates.append(m)
                            matchedLabels.append("\(label)(\(String(format: "%.0f", obs.confidence * 100))%)")
                        }
                    }
                    if candidates.count >= 3 { break }
                }

                // 去重，最多 3 个候选（更聚焦）
                candidates = Array(candidates.prefix(3))

                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.analyzeButton.isEnabled = true

                    if candidates.isEmpty {
                        // 识别失败：自动跳转搜索，不给错误答案
                        self.showSearchFallback()
                    } else {
                        self.candidates = candidates
                        self.resultCard.isHidden = false
                        self.candidateTable.reloadData()
                    }
                }
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }

    // MARK: - 识别失败降级：跳转搜索
    private func showSearchFallback() {
        let alert = UIAlertController(
            title: L("camera.no_match.title"),
            message: L("camera.no_match.message"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L("camera.no_match.search"), style: .default) { [weak self] _ in
            guard let self = self else { return }
            let searchVC = FoodSearchViewController()
            searchVC.onFoodSelected = self.onFoodSelected
            self.navigationController?.pushViewController(searchVC, animated: true)
        })
        alert.addAction(UIAlertAction(title: L("camera.no_match.retry"), style: .cancel))
        present(alert, animated: true)
    }

    @objc private func dismiss_() { dismiss(animated: true) }
}

// MARK: - UIImagePickerControllerDelegate
extension FoodCameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            capturedImage = image
            imageView.image = image
            analyzeButton.isHidden = false
        }
    }
}

// MARK: - TableView (Candidates)
extension FoodCameraViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { candidates.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FoodSearchCell.reuseID, for: indexPath) as! FoodSearchCell
        cell.configure(with: candidates[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let food = candidates[indexPath.row]
        let alert = UIAlertController(title: food.localizedName, message: L("food.enter_weight"), preferredStyle: .alert)
        alert.addTextField { tf in tf.placeholder = "100"; tf.keyboardType = .numberPad; tf.text = "100" }
        alert.addAction(UIAlertAction(title: L("common.cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: L("common.add"), style: .default) { [weak self] _ in
            guard let self = self else { return }
            let weight = Double(alert.textFields?.first?.text ?? "100") ?? 100
            self.onFoodSelected?(food, weight, self.selectedMealType)
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}
