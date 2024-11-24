import { Result } from "@/app/core/result";
import { ConversationDataDto } from "../../data/dto/ConversationData.dto";
import { ConversationsDataDto } from "../../data/dto/ConversationsData.dto";
import { ConversationsDto } from "../../data/dto/Conversations.dto";
import { Observable } from "rxjs";

export interface ChatRepository {
  connectChatStream(): Observable<Result<ConversationsDto>>;
  getConversation(page: number): Promise<Result<ConversationDataDto>>;
  getConversations(
    conversationsId: string,
    page: number
  ): Promise<Result<ConversationsDataDto>>;
  sendMessage(recipient: string, content: string): Promise<Result<boolean>>;
}
