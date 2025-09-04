import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static values = { taskToken: String }

  connect() {
    console.log('TaskCommentsController connected for task:', this.taskTokenValue)
    this.consumer = createConsumer()
    this.subscription = this.consumer.subscriptions.create(
      { 
        channel: "TaskCommentsChannel", 
        task_token: this.taskTokenValue 
      },
      {
        connected: () => {
          console.log('WebSocket connected to TaskCommentsChannel')
        },
        disconnected: () => {
          console.log('WebSocket disconnected from TaskCommentsChannel')
        },
        received: (data) => {
          console.log('Received WebSocket message:', data)
          this.handleMessage(data)
        }
      }
    )
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  handleMessage(data) {
    console.log('Handling message:', data.action)
    switch (data.action) {
      case "comment_created":
        console.log('Adding comment:', data.comment)
        this.addComment(data.comment)
        this.updateCommentCount()
        break
      case "comment_deleted":
        console.log('Removing comment:', data.comment_token)
        this.removeComment(data.comment_token)
        this.updateCommentCount()
        break
    }
  }

  addComment(commentData) {
    const commentsList = this.element // this.element is already #comments-list
    const noCommentsMessage = commentsList.querySelector("p.text-muted")
    
    if (noCommentsMessage) {
      noCommentsMessage.remove()
    }

    const commentElement = document.createElement("div")
    commentElement.id = `comment-${commentData.token}`
    commentElement.innerHTML = this.renderComment(commentData)
    
    commentsList.appendChild(commentElement)
  }

  removeComment(commentToken) {
    const commentElement = document.getElementById(`comment-${commentToken}`)
    if (commentElement) {
      commentElement.remove()
    }
  }

  updateCommentCount() {
    const commentsList = this.element // this.element is already #comments-list
    const commentCount = commentsList.querySelectorAll("div[id^='comment-']").length
    const badge = document.getElementById("comments-count")
    if (badge) {
      badge.textContent = commentCount
    }
  }

  renderComment(commentData) {
    return `
      <div class="border-bottom pb-3 mb-3">
        <div class="d-flex justify-content-between align-items-start">
          <div class="flex-grow-1">
            <div class="d-flex align-items-center gap-2">
              <div class="fw-bold">${commentData.user_name}</div>
              <div class="text-muted small">${commentData.time_ago}</div>
            </div>
            <div class="mt-2">${commentData.text}</div>
          </div>
          <form action="/to_do_items/${this.taskTokenValue}/comments/${commentData.token}" method="post" class="d-inline" data-turbo-method="delete">
            <input type="hidden" name="authenticity_token" value="${document.querySelector('meta[name="csrf-token"]').content}">
            <button type="submit" class="btn btn-sm btn-outline-danger" title="Delete comment">
              <i class="fas fa-times"></i>
            </button>
          </form>
        </div>
      </div>
    `
  }
}
