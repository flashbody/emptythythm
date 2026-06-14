import UIKit

// MARK: - AI 助手页面
class AIAssistantViewController: UIViewController {

    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let inputBar = UIView()
    private let inputField = UITextField()
    private let sendButton = UIButton(type: .system)
    private let quickQuestionsView = UIView()
    private let disclaimerBanner = UILabel()
    private var inputBarBottomConstraint: NSLayoutConstraint!

    // MARK: - Data
    private var messages: [(isUser: Bool, content: String)] = []
    private var isLoading = false

    // Quick questions
    private let quickQuestions: [String] = [
        "quick.q1", "quick.q2", "quick.q3", "quick.q4", "quick.q5", "quick.q6"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.setPageBackground()
        title = L("tab.ai")
        setupUI()
        setupKeyboardObservers()
        addWelcomeMessage()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup
    private func setupUI() {
        // Disclaimer banner
        disclaimerBanner.text = L("ai.disclaimer")
        disclaimerBanner.font = UIFont.systemFont(ofSize: 11)
        disclaimerBanner.textColor = AppColor.textSub
        disclaimerBanner.textAlignment = .center
        disclaimerBanner.numberOfLines = 2
        disclaimerBanner.backgroundColor = AppColor.bgSecondary
        disclaimerBanner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(disclaimerBanner)

        // Quick questions
        setupQuickQuestions()

        // TableView (chat messages)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.reuseID)
        tableView.separatorStyle = .none
        tableView.backgroundColor = AppColor.bgPage
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)

        // Input bar
        inputBar.backgroundColor = AppColor.bgCard
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputBar)

        inputField.placeholder = L("ai.input.placeholder")
        inputField.font = AppUIStyle.fontBody
        inputField.backgroundColor = AppColor.bgSecondary
        inputField.layer.cornerRadius = 18
        inputField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        inputField.leftViewMode = .always
        inputField.returnKeyType = .send
        inputField.delegate = self
        inputField.translatesAutoresizingMaskIntoConstraints = false
        inputBar.addSubview(inputField)

        sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        sendButton.tintColor = AppColor.mainTint
        sendButton.imageView?.contentMode = .scaleAspectFit
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        inputBar.addSubview(sendButton)

        inputBarBottomConstraint = inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            disclaimerBanner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            disclaimerBanner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            disclaimerBanner.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            disclaimerBanner.heightAnchor.constraint(equalToConstant: 36),

            quickQuestionsView.topAnchor.constraint(equalTo: disclaimerBanner.bottomAnchor),
            quickQuestionsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            quickQuestionsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            quickQuestionsView.heightAnchor.constraint(equalToConstant: 44),

            tableView.topAnchor.constraint(equalTo: quickQuestionsView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputBar.topAnchor),

            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBar.heightAnchor.constraint(equalToConstant: 60),
            inputBarBottomConstraint,

            inputField.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor, constant: 16),
            inputField.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            inputField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            inputField.heightAnchor.constraint(equalToConstant: 36),

            sendButton.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 36),
            sendButton.heightAnchor.constraint(equalToConstant: 36),
        ])
    }

    private func setupQuickQuestions() {
        quickQuestionsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(quickQuestionsView)

        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        quickQuestionsView.addSubview(scroll)

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        for (i, key) in quickQuestions.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(L(key), for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            btn.setTitleColor(AppColor.aiBlue, for: .normal)
            btn.backgroundColor = AppColor.aiBlue.withAlphaComponent(0.1)
            btn.layer.cornerRadius = 14
            btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
            btn.tag = i
            btn.addTarget(self, action: #selector(quickQuestionTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(btn)
        }

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: quickQuestionsView.topAnchor, constant: 4),
            scroll.leadingAnchor.constraint(equalTo: quickQuestionsView.leadingAnchor, constant: 16),
            scroll.trailingAnchor.constraint(equalTo: quickQuestionsView.trailingAnchor, constant: -16),
            scroll.bottomAnchor.constraint(equalTo: quickQuestionsView.bottomAnchor, constant: -4),
            stack.topAnchor.constraint(equalTo: scroll.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            stack.heightAnchor.constraint(equalTo: scroll.heightAnchor),
        ])
    }

    // MARK: - Keyboard
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ note: Notification) {
        guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        inputBarBottomConstraint.constant = -frame.height + view.safeAreaInsets.bottom
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }

    @objc private func keyboardWillHide(_ note: Notification) {
        inputBarBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }

    // MARK: - Messages
    private func addWelcomeMessage() {
        let welcome = L("ai.welcome")
        messages.append((isUser: false, content: welcome))
        tableView.reloadData()
    }

    @objc private func quickQuestionTapped(_ sender: UIButton) {
        let question = L(quickQuestions[sender.tag])
        sendUserMessage(question)
    }

    @objc private func sendMessage() {
        guard let text = inputField.text, !text.isEmpty else { return }
        inputField.text = ""
        sendUserMessage(text)
    }

    private func sendUserMessage(_ text: String) {
        messages.append((isUser: true, content: text))
        tableView.reloadData()
        scrollToBottom()

        // Show typing indicator
        messages.append((isUser: false, content: "..."))
        tableView.reloadData()
        scrollToBottom()

        // Generate AI response
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.8) {
            let response = self.generateResponse(for: text)
            DispatchQueue.main.async {
                self.messages.removeLast() // Remove typing indicator
                self.messages.append((isUser: false, content: response))
                self.tableView.reloadData()
                self.scrollToBottom()
                self.saveToHistory(user: text, ai: response)
            }
        }
    }

    private func generateResponse(for question: String) -> String {
        let q = question.lowercased()
        let profile = UserProfileService.shared.currentProfile

        // Rule-based response engine (Foundation Models integration point)
        if q.contains("断食") && q.contains("喝") || q.contains("can i drink") || q.contains("trinken") {
            return L("ai.response.drinks")
        }
        if q.contains("头晕") || q.contains("dizzy") || q.contains("schwindel") {
            return L("ai.response.dizzy")
        }
        if q.contains("饥饿") || q.contains("hungry") || q.contains("hunger") {
            return L("ai.response.hunger")
        }
        if q.contains("方案") || q.contains("plan") || q.contains("plan") {
            if let p = profile {
                let plan = AIFastPlanEngine.shared.ruleBasedRecommendation(for: p)
                return String(format: L("ai.response.plan"), plan.name, plan.fastHour, plan.eatHour)
            }
            return L("ai.response.plan_no_profile")
        }
        if q.contains("卡路里") || q.contains("calorie") || q.contains("kalorien") {
            if let p = profile {
                return String(format: L("ai.response.calorie"), Int(p.dailyTargetCalorie), Int(p.calorieDeficit))
            }
            return L("ai.response.calorie_no_profile")
        }
        if q.contains("体重") || q.contains("weight") || q.contains("gewicht") {
            return L("ai.response.weight")
        }
        if q.contains("运动") || q.contains("exercise") || q.contains("sport") {
            return L("ai.response.exercise")
        }
        if q.contains("经期") || q.contains("period") || q.contains("menstruation") {
            return L("ai.response.period")
        }
        if q.contains("新手") || q.contains("beginner") || q.contains("anfänger") {
            return L("ai.response.beginner")
        }

        return L("ai.response.default")
    }

    private func saveToHistory(user: String, ai: String) {
        let ctx = CoreDataManager.shared.context
        let record = AIChatRecord(context: ctx)
        record.chatID = UUID().uuidString
        record.userContent = user
        record.aiContent = ai
        record.chatTime = Date()
        record.isSoftDeleted = false
        CoreDataManager.shared.save()
    }

    private func scrollToBottom() {
        guard messages.count > 0 else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

// MARK: - TableView
extension AIAssistantViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { messages.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.reuseID, for: indexPath) as! ChatMessageCell
        let msg = messages[indexPath.row]
        cell.configure(content: msg.content, isUser: msg.isUser)
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension AIAssistantViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}

// MARK: - ChatMessageCell
class ChatMessageCell: UITableViewCell {
    static let reuseID = "ChatMessageCell"

    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private let avatarView = UIView()
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        bubbleView.layer.cornerRadius = 16
        bubbleView.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.setBodyStyle()
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(messageLabel)

        contentView.addSubview(bubbleView)

        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),

            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(content: String, isUser: Bool) {
        messageLabel.text = content
        if isUser {
            bubbleView.backgroundColor = AppColor.mainTint
            messageLabel.textColor = .white
            leadingConstraint.isActive = false
            trailingConstraint.isActive = true
        } else {
            bubbleView.backgroundColor = AppColor.bgCard
            messageLabel.textColor = AppColor.textMain
            trailingConstraint.isActive = false
            leadingConstraint.isActive = true
        }
    }
}
