import axiosInstance from "@/app/core/interceptor";
import { ConversationDataDto } from "../dto/ConversationData.dto";
import { config } from "@/app/core/config";
import axios, { AxiosError } from "axios";
import { ConversationsDataDto } from "../dto/ConversationsData.dto";
import { Observable } from "rxjs";
import { ConversationsDto } from "../dto/Conversations.dto";
import { fetchEventSource } from "@microsoft/fetch-event-source";
export class ChatRemoteDatasource {
  connectChatStream(accessToken: string): Observable<ConversationsDto> {
    return new Observable<ConversationsDto>((observer) => {
      // Set up the SSE connection with the authorization header
      fetchEventSource(`${config.quickChatSSEService}/chat/events`, {
        method: "GET",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          Accept: "text/event-stream",
        },
        onopen: async (response) => {
          if (response.ok) {
            console.log("SSE connection opened.");
          } else {
            observer.error(`Error: ${response.statusText}`);
          }
        },
        onmessage(event) {
          try {
            const data = JSON.parse(event.data);
            const message: ConversationsDto = {
              sender: data.sender,
              recipient: data.recipient,
              sentAt: data.sentAt,
              content: data.content,
            };
            observer.next(message);
          } catch (error) {
            observer.error("Error parsing message data");
          }
        },
        onerror(error) {
          observer.error("SSE connection error");
          console.error("SSE Error:", error);
        },
        onclose() {
          console.log("SSE connection closed.");
          observer.complete();
        },
      });

      // Clean up when the observable is unsubscribed
      return () => {
        console.log("SSE stream unsubscribed.");
      };
    });
  }

  async getConversation(page: number): Promise<ConversationDataDto> {
    try {
      const rawData = {
        page: page,
      };

      const response = await axiosInstance.get<{ data: any }>(
        `${config.quickChatService}/conversation`,
        { params: rawData }
      );

      if (response.status === 200 && response.data?.data) {
        const data = response.data.data;
        return {
          currentPage: data.currentPage,
          maxPage: data.maxPage,
          conversationList: data.conversationList,
        };
      }

      throw new Error("Invalid response format");
    } catch (error) {
      throw this.checkErrResponse(error);
    }
  }

  async getConversations(
    conversationsId: string,
    page: number
  ): Promise<ConversationsDataDto> {
    try {
      const rawData = {
        conversationsId: conversationsId,
        page: page,
      };

      const response = await axiosInstance.get<{ data: any }>(
        `${config.quickChatService}/conversations`,
        { params: rawData }
      );

      if (response.status === 200 && response.data?.data) {
        const data = response.data.data;
        return {
          currentPage: data.currentPage,
          maxPage: data.maxPage,
          conversationsList: data.conversationsList,
        };
      }

      throw new Error("Invalid response format");
    } catch (error) {
      throw this.checkErrResponse(error);
    }
  }

  async sendMessage(recipient: string, content: string): Promise<boolean> {
    try {
      const rawData = {
        recipient: recipient,
        content: content,
      };

      const response = await axiosInstance.post<{ data: any }>(
        `${config.quickChatService}/chat/send`,
        rawData
      );

      // trigger sse
      await axiosInstance.post<{ data: any }>(
        `${config.quickChatSSEService}/chat/send`,
        rawData
      );

      if (response.status === 201) {
        return true;
      }

      throw new Error("Invalid response format");
    } catch (error) {
      throw this.checkErrResponse(error);
    }
  }

  // Private Methods
  //
  private checkErrResponse(error: any): Error {
    if (axios.isAxiosError(error)) {
      const axiosError = error as AxiosError<any>;
      const response = axiosError.response;

      if (!response) {
        return new Error("No response received");
      }

      // Handle specific error cases
      if (response.data?.message?.message === "jwt expired") {
        return new Error("Session expired");
      }

      // Return the error message from the response if available
      const errorMessage =
        response.data?.message?.message ||
        response.data?.message ||
        response.data?.error ||
        "Unknown error occurred";

      return new Error(errorMessage);
    }

    return new Error("An unexpected error occurred");
  }
}
