import { UserDataDto } from "@/app/features/authentication/data/dto/UserData.dto";

export class SearchDataDto {
  constructor(
    public currentPage: string,
    public maxPage: string,
    public users: UserDataDto[]
  ) {}
}
