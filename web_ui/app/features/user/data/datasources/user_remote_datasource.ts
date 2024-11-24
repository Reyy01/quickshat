import axiosInstance from "@/app/core/interceptor";
import { SearchDataDto } from "../dto/SearchData.dto";
import { SearchUserDto } from "../dto/SearchUser.dto";
import { config } from "@/app/core/config";
import axios, { AxiosError } from "axios";

export class UserRemoteDatasource {
  async search(searchUserDto: SearchUserDto): Promise<SearchDataDto> {
    try {
      const rawData = {
        searchQuery: searchUserDto.querySearch,
        page: searchUserDto.page,
      };

      const response = await axiosInstance.get<{ data: any }>(
        `${config.quickChatService}/search`,
        { params: rawData }
      );

      if (response.status === 200 && response.data?.data) {
        const data = response.data.data;
        return {
          currentPage: data.currentPage,
          maxPage: data.maxPage,
          users: data.users,
        };
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
