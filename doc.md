# Graduate Chronicles - Technical Overview

## 1. Executive Summary

This document provides a high-level technical overview of the **Graduate Chronicles** application. It details our architectural patterns, technology stack, and development methodology, with a specific deep-dive into the secure **Real-time Messaging** feature to illustrate our coding standards and structural decisions.

---

## 2. Technology Stack

Our application leverages a modern, cross-platform stack designed for performance, scalability, and developer experience.

| Category | Technology | Description |
| :--- | :--- | :--- |
| **Framework** | **Flutter** | Google's UI toolkit for building natively compiled applications from a single codebase. |
| **Language** | **Dart** | Optimized for fast apps on any platform, providing sound null safety. |
| **State Management** | **Riverpod** | A reactive caching and data-binding framework that ensures compile-time safety and testability. |
| **Backend / DB** | **Supabase** | An open-source Firebase alternative providing Postgres database, Authentication, Realtime subscriptions, and Storage. |
| **Authentication** | **Supabase Auth** | Secure user management and authentication flows. |
| **Styling** | **Custom Design System** | A centralized `DesignSystem` class for consistent typography, colors, and components. |
| **Security** | **Client-Side Encryption** | Custom encryption service for sensitive data like messages. |


---

## 3. Design System & UI/UX

We maintain a strict separation of design tokens from UI components to ensure consistency and ease of theming.

### 3.1. Design Tokens (`lib/theme/design_system.dart`)
A centralized static class defines our visual language:

*   **Color Palette**: A dark-themed premium aesthetic using deeply saturated purples and vibrant accents.
    *   **Background**: `purpleDark` (`#0F0410`) - Deep, almost black purple.
    *   **Primary Accent**: `purpleAccent` (`#9B2CFF`) - Vibrant electric purple.
    *   **Warm Accent**: `warmYellow` (`#FBDE36`) - For highlights and calls to action.
*   **Typography**:
    *   **Headings**: `GoogleFonts.outfit` - Modern, geometric sans-serif for impact.
    *   **Body**: `GoogleFonts.inter` - Clean, highly readable for density.

### 3.2. Architecture Overview

### 3.1. High-Level Architecture (3-Tier & MVVM)
Our codebase follows a robust **3-Tier Architecture** mapped to the **MVP (Model-View-ViewModel)** pattern suitable for Flutter. This ensures Separation of Concerns (SoC), making the codebase modular, testable, and maintainable.

#### The 3 Layers:
1.  **Presentation Layer (View)**: handling UI and user interactions.
2.  **Application Logic Layer (ViewModel)**: managing state, business logic, and connecting UI to data.
3.  **Data Layer (Model)**: handling data retrieval, storage, and external API communication.

```mermaid
graph TD
    classDef view fill:#e1f5fe,stroke:#01579b,stroke-width:2px;
    classDef logic fill:#fff3e0,stroke:#ff6f00,stroke-width:2px;
    classDef data fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px;

    subgraph Presentation ["Presentation Layer (View)"]
        UI[Screens & Widgets]:::view
    end

    subgraph Logic ["Application Logic (ViewModel)"]
        Notifier[Riverpod Notifiers]:::logic
        Providers[State Providers]:::logic
    end

    subgraph Data ["Data Layer (Model)"]
        Service[Services (Supabase/API)]:::data
        Model[Data Models]:::data
        DB[(Supabase / Postgres)]:::data
    end

    UI <--> Notifier
    Notifier <--> Service
    Service <--> Model
    Service <--> DB
```

### 3.2. Modular Feature Structure
We adopt a **Feature-Driven** directory structure. Instead of grouping files by type (e.g., all controllers together), we group them by **feature**.

**Example Structure:**
```text
lib/
├── core/                   <-- Shared utilities (App config, Global Providers)
├── messaging/              <-- [Feature] Real-time Chat Module
│   ├── models/
│   ├── providers/
│   ├── services/
│   └── ui/
├── services/               <-- Global Services (Supabase, Encryption, AI)
├── theme/                  <-- Design System & Assets
└── ui/                     <-- Feature-Specific UI Modules
    ├── auth/               <-- Authentication & Onboarding
    ├── community/          <-- Events & Reunion Logic
    ├── home/               <-- Dashboard & Main Feeds
    ├── notifications/      <-- Activity Center
    ├── portfolio/          <-- User Portfolios & Projects
    ├── profile/            <-- User Profiles & Settings
    ├── yearbook/           <-- Digital Yearbook Feature
    └── widgets/            <-- Reusable UI Components
```

---

## 4. Feature Spotlight: Secure Real-time Messaging

To illustrate our architecture in practice, we examine the **Messaging Feature**. This module handles real-time end-to-end encrypted chat.

### 4.1. Structure & Flow
1.  **UI**: `ChatScreen` subscribes to a stream of messages.
2.  **State**: `messagesStreamProvider` listens to the service and emits updates.
3.  **Service**: `MessagingService` connects to Supabase Realtime, listens for Postgres changes, decrypts incoming data, and yields `Message` objects.

### 4.2. Code Snippets

#### A. Data Layer (`MessagingService`)
Encapsulates direct DB interaction and encryption logic. Notice how it handles transformation from raw JSON to domain entities.

```dart
/// Service handling all messaging operations with Supabase.
class MessagingService {
  final SupabaseClient _client;
  // ...

  /// Get real-time stream of messages for a conversation.
  /// Uses Supabase Realtime with Postgres Changes.
  Stream<List<Message>> getMessagesStream(String conversationId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .map((rows) {
          return rows.map((r) {
            // Decrypt content before creating model
            final content = r['content'] as String;
            try {
              final decrypted = _encryption.decrypt(content);
              final mutableMap = Map<String, dynamic>.from(r);
              mutableMap['content'] = decrypted;
              return Message.fromMap(mutableMap);
            } catch (e) {
              return Message.fromMap(r); // Fallback
            }
          }).toList();
        });
  }
}
```

#### B. Logic Layer (`MessagingProvider`)
Uses Riverpod to abstract the service from the UI. The UI never talks to `MessagingService` directly; it watches this provider.

```dart
/// Stream provider for real-time messages.
/// Usage: ref.watch(messagesStreamProvider(conversationId))
final messagesStreamProvider = StreamProvider.family<List<Message>, String>((
  ref,
  conversationId,
) {
  final service = ref.read(messagingServiceProvider);
  return service.getMessagesStream(conversationId);
});
```

#### C. Presentation Layer (`ChatScreen`)
A `ConsumerStatefulWidget` that reacts to state changes. It handles UI-specific logic like scrolling and input, but delegates data fetching to the provider.

```dart
class ChatScreen extends ConsumerStatefulWidget {
  // ...
  @override
  Widget build(BuildContext context) {
    // Watch the stream provider for real-time updates
    final messagesAsync = ref.watch(
      messagesStreamProvider(widget.conversationId),
    );

    return Scaffold(
      body: GlobalBackground(
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                data: (messages) => _buildMessageList(messages, currentUserId),
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error: $err'),
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }
}
```


---

## 5. AI & Machine Learning Capabilities

We leverage a **Hybrid Recommendation Engine** to deliver personalized content, combining collaborative filtering with semantic search.

### 5.1. Multi-Tiered Recommendation Strategy
Our system (`PersonalizedFeedNotifier`) uses a waterfall approach to ensure relevant content is always available:

1.  **Primary: Gorse AI (Collaborative Filtering)**
    *   **Goal**: Recommend items based on user behavior patterns (likes, reads) and similar users.
    *   **Implementation**: `GorseService` communicates with a self-hosted Gorse instance.
    *   **Feedback Loop**: User interactions (likes, reads) are asynchronously synced to Gorse for real-time model training.

2.  **Secondary: Supabase Vector Search (Semantic Embedding)**
    *   **Goal**: Recommend items semantically similar to a user's stated interests.
    *   **Implementation**: `SupabaseRecommender` uses `pgvector` to find posts with embeddings close to the user's interest profile.
    *   **Embeddings**: Generated via **text-embedding-3-small** and stored in `posts.embedding` (`vector(384)`).

3.  **Fallback: Keyword-Based Matching**
    *   **Goal**: Simple text matching if advanced models return no results or are unavailable.

#### Code Snippet: Recommendation Waterfall (`PersonalizedFeedNotifier`)
The logic layer orchestrates these services seamlessly:

```dart
Future<List<PostItem>> _fetchPersonalizedFeed() async {
  // ...
  
  // 1. Try Gorse AI (Collaborative Filtering)
  try {
    final gorseItemIds = await GorseService.getRecommendations(userId);
    if (gorseItemIds.isNotEmpty) {
       // Convert IDs to Post objects...
       recommendedPosts.addAll(gorsePosts);
    }
  } catch (e) {
    // Gorse unavailable, continue to next layer
  }

  // 2. Fallback to Supabase Vector Search (Semantic)
  if (recommendedPosts.isEmpty) {
    final rawRecs = await SupabaseRecommender.getRecommendations(
      interests: userInterests,
    );
    // Add to list...
  }

  // 3. Last Resort: Keyword Matching
  if (recommendedPosts.isEmpty) {
    // ...
  }
  
  // 4. Mix with chronological feed for variety
  return _mixFeed(recommendedPosts, chronologicalPosts);
}
```

---

## 6. Agile Methodology

We utilize an **Agile / Scrum-ban** methodology to ensure rapid delivery and adaptability.

*   **Iterative Development**: Features like Messaging were built in distinct phases (Audit -> Schema Design -> MVP Implementation -> UI Refinement).
*   **User-Centric**: Tasks are defined as user objectives (e.g., "Fixing Report Duplicates", "Implementing Light Mode").
*   **Continuous Integration**: Code is continuously integrated, with valid compilation and lint checks required before completion.
*   **Feedback Loops**: Frequent "Verify" steps and walkthroughs ensure that implemented features match user requirements before moving to the next task.
