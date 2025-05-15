document.addEventListener('DOMContentLoaded', function() {
    // Sample data - in a real app, this would come from your database
    const chats = [
        {
            id: '1',
            name: 'John Doe',
            avatar: 'https://via.placeholder.com/50',
            lastMessage: 'Hey, how are you doing?',
            time: '12:30 PM',
            unreadCount: 2,
            messages: [
                {
                    id: '1',
                    content: 'Hey there!',
                    sender: 'John Doe',
                    time: '12:20 PM',
                    status: 'seen'
                },
                {
                    id: '2',
                    content: 'How are you?',
                    sender: 'John Doe',
                    time: '12:22 PM',
                    status: 'seen'
                },
                {
                    id: '3',
                    content: "I'm good, thanks! How about you?",
                    sender: 'Me',
                    time: '12:25 PM',
                    status: 'seen'
                },
                {
                    id: '4',
                    content: 'Hey, how are you doing?',
                    sender: 'John Doe',
                    time: '12:30 PM',
                    status: 'delivered'
                }
            ]
        },
        {
            id: '2',
            name: 'Family Group',
            avatar: 'https://via.placeholder.com/50/ffcc00',
            lastMessage: 'Mom: Dinner at 8pm tonight',
            time: '11:45 AM',
            unreadCount: 5,
            isGroup: true,
            messages: [
                {
                    id: '1',
                    content: 'Dad: Who is coming for the weekend?',
                    sender: 'Dad',
                    time: '11:30 AM',
                    status: 'seen'
                },
                {
                    id: '2',
                    content: 'Sister: I will be there!',
                    sender: 'Sister',
                    time: '11:35 AM',
                    status: 'seen'
                },
                {
                    id: '3',
                    content: 'Me: I have work, maybe Sunday',
                    sender: 'Me',
                    time: '11:40 AM',
                    status: 'seen'
                },
                {
                    id: '4',
                    content: 'Mom: Dinner at 8pm tonight',
                    sender: 'Mom',
                    time: '11:45 AM',
                    status: 'delivered'
                }
            ]
        },
        {
            id: '3',
            name: 'Jane Smith',
            avatar: 'https://via.placeholder.com/50/ccff00',
            lastMessage: 'The documents are ready',
            time: 'Yesterday',
            unreadCount: 0,
            messages: [
                {
                    id: '1',
                    content: 'Hi, do you have those files?',
                    sender: 'Me',
                    time: 'Yesterday, 4:30 PM',
                    status: 'seen'
                },
                {
                    id: '2',
                    content: 'Yes, I was working on them',
                    sender: 'Jane Smith',
                    time: 'Yesterday, 6:45 PM',
                    status: 'seen'
                },
                {
                    id: '3',
                    content: 'The documents are ready',
                    sender: 'Jane Smith',
                    time: 'Yesterday, 6:50 PM',
                    status: 'seen'
                }
            ]
        }
    ];

    // Render chat list
    function renderChatList() {
        const chatList = document.getElementById('chatList');
        chatList.innerHTML = '';
        
        chats.forEach(chat => {
            const chatItem = document.createElement('div');
            chatItem.className = 'chat-item d-flex align-items-center';
            chatItem.innerHTML = `
                <img src="${chat.avatar}" alt="${chat.name}" class="rounded-circle me-3 chat-img">
                <div class="flex-grow-1">
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="fw-bold">${chat.name}</span>
                        <small class="time">${chat.time}</small>
                    </div>
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="last-message">${chat.lastMessage}</span>
                        ${chat.unreadCount > 0 ? `<span class="unread-count">${chat.unreadCount}</span>` : ''}
                    </div>
                </div>
            `;
            
            chatItem.addEventListener('click', () => loadChat(chat.id));
            chatList.appendChild(chatItem);
        });
    }

    // Load chat messages
    function loadChat(chatId) {
        const chat = chats.find(c => c.id === chatId);
        if (!chat) return;
        
        // Update chat header
        const chatHeader = document.querySelector('.chat-header');
        chatHeader.innerHTML = `
            <div class="d-flex align-items-center">
                <img src="${chat.avatar}" alt="${chat.name}" class="rounded-circle me-2 profile-img">
                <div>
                    <div class="fw-bold">${chat.name}</div>
                    <small class="text-muted">last seen today at 12:45 PM</small>
                </div>
            </div>
            <div>
                <button class="btn btn-sm btn-outline-secondary me-2">
                    <i class="fas fa-search"></i>
                </button>
                <button class="btn btn-sm btn-outline-secondary me-2">
                    <i class="fas fa-phone"></i>
                </button>
                <button class="btn btn-sm btn-outline-secondary me-2">
                    <i class="fas fa-video"></i>
                </button>
                <button class="btn btn-sm btn-outline-secondary">
                    <i class="fas fa-ellipsis-vertical"></i>
                </button>
            </div>
        `;
        
        // Render messages
        const messagesArea = document.getElementById('messagesArea');
        messagesArea.innerHTML = '';
        
        chat.messages.forEach(message => {
            const isSent = message.sender === 'Me';
            const messageElement = document.createElement('div');
            messageElement.className = `message ${isSent ? 'sent' : 'received'}`;
            
            messageElement.innerHTML = `
                <div>${message.content}</div>
                <div class="d-flex justify-content-end align-items-center">
                    <small class="time">${message.time}</small>
                    ${isSent ? `<i class="fas fa-${message.status === 'seen' ? 'check-double' : 'check'} status"></i>` : ''}
                </div>
            `;
            
            messagesArea.appendChild(messageElement);
        });
        
        // Scroll to bottom
        messagesArea.scrollTop = messagesArea.scrollHeight;
        
        // Mark as read
        if (chat.unreadCount > 0) {
            chat.unreadCount = 0;
            renderChatList();
        }
    }

    // Send message
    document.getElementById('sendMessageBtn').addEventListener('click', function() {
        const messageInput = document.getElementById('messageInput');
        const message = messageInput.value.trim();
        
        if (message) {
            // In a real app, you would send this to your backend
            const messagesArea = document.getElementById('messagesArea');
            const now = new Date();
            const timeString = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
            
            const messageElement = document.createElement('div');
            messageElement.className = 'message sent';
            messageElement.innerHTML = `
                <div>${message}</div>
                <div class="d-flex justify-content-end align-items-center">
                    <small class="time">${timeString}</small>
                    <i class="fas fa-check status"></i>
                </div>
            `;
            
            messagesArea.appendChild(messageElement);
            messageInput.value = '';
            
            // Scroll to bottom
            messagesArea.scrollTop = messagesArea.scrollHeight;
            
            // Simulate reply after 1 second
            setTimeout(() => {
                const replyElement = document.createElement('div');
                replyElement.className = 'message received';
                replyElement.innerHTML = `
                    <div>This is an automated reply to: "${message}"</div>
                    <div class="d-flex justify-content-end align-items-center">
                        <small class="time">${timeString}</small>
                    </div>
                `;
                messagesArea.appendChild(replyElement);
                messagesArea.scrollTop = messagesArea.scrollHeight;
            }, 1000);
        }
    });

    // Allow sending message with Enter key
    document.getElementById('messageInput').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            document.getElementById('sendMessageBtn').click();
        }
    });

    // Initialize the app
    renderChatList();
    if (chats.length > 0) {
        loadChat(chats[0].id);
    }
});