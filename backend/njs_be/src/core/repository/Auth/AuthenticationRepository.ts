import { Either } from "../../../utils/Either";
import { LoginDto } from "../../dto/Auth/Login.dto";
import { ErrorResponse } from "../../entity/ErrorRespose.entity";
import { LoggedDataEntity } from "../../entity/LoggedData.entity";

export interface AuthenticationRepository {
  login(loginDto: LoginDto): Promise<Either<ErrorResponse, LoggedDataEntity>>;
}
