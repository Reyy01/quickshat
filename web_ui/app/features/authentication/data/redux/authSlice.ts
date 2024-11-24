import { createSlice, createAsyncThunk, PayloadAction } from "@reduxjs/toolkit";
import { LoginUserDto } from "../dto/LoginUser.dto";
import { LoginDatasDto } from "../dto/LoginData.dto";

import { AuthRepositoryImpl } from "../repositories/auth_repository_impl";
import { AuthRemoteDatasource } from "../datasources/auth_remote_datasource";
import { AuthStatus, NavigatePage, StateStatus } from "@/app/core/types";
import { AuthLocalDataSource } from "../datasources/auth_local_datasource";

const authRemoteDatasource = new AuthRemoteDatasource();
const authLocalDatasource = new AuthLocalDataSource();

// repository instance
const authRepository = new AuthRepositoryImpl(
  authRemoteDatasource,
  authLocalDatasource
);

interface AuthState {
  loginDatas: LoginDatasDto | null;
  errorMessage: string | null;
  stateStatus: StateStatus;
  navigatePage: NavigatePage;
  authStatus: AuthStatus;
}

const initialState: AuthState = {
  loginDatas: null,
  errorMessage: null,
  stateStatus: StateStatus.INITIAL,
  navigatePage: NavigatePage.LOGIN,
  authStatus: AuthStatus.UNAUTHENTICATED,
};

export const loginUser = createAsyncThunk(
  "auth/loginUser",
  async (loginUserDto: LoginUserDto) => {
    const result = await authRepository.loginUser(loginUserDto);
    if (!result.isSuccess) {
      throw new Error(result.getError);
    }
    return result.getValue;
  }
);

// Slice
const authSlice = createSlice({
  name: "auth",
  initialState,
  reducers: {
    load(state) {
      state.stateStatus = StateStatus.LOADED;
    },
  },
  extraReducers: (builder) => {
    // Login User
    builder
      .addCase(loginUser.pending, (state) => {
        state.stateStatus = StateStatus.LOADING;
      })
      .addCase(
        loginUser.fulfilled,
        (state, action: PayloadAction<LoginDatasDto>) => {
          state.stateStatus = StateStatus.LOADED;
          state.authStatus = AuthStatus.AUTHENTICATED;
          state.loginDatas = action.payload;
          state.navigatePage = NavigatePage.HOME;
        }
      )
      .addCase(loginUser.rejected, (state, action) => {
        state.stateStatus = StateStatus.ERROR;
        state.errorMessage = action.error.message ?? "Login failed";
      })
      .addDefaultCase((state) => {
        state.stateStatus = StateStatus.LOADED;
      });
  },
});

export default authSlice.reducer;
