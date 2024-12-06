import { formatDistanceToNow } from "date-fns";

export class DateUtils {
  static formatTimeAgo(dateString: string): string {
    try {
      const date = new Date(dateString);
      return `${formatDistanceToNow(date, { addSuffix: true })}`;
    } catch (error) {
      console.error("Invalid date format:", error);
      return "Invalid date";
    }
  }

  static formatTime(
    dateString: string,
    options: Intl.DateTimeFormatOptions = {
      hour: "2-digit",
      minute: "2-digit",
    }
  ): string {
    return new Date(dateString).toLocaleTimeString([], options);
  }
}
