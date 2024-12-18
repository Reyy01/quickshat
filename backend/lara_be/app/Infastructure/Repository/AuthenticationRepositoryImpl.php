<?php
namespace App\Infastructure\Repository;

use App\Domain\Auth\Repositories\AuthenticationRepository;
use App\Domain\Auth\DTO\LoginDto;
use App\Domain\Auth\DTO\LoggedDataDto;
use App\Domain\User\Entities\UserEntity;
use App\Domain\Auth\Entities\ErrorResponse;
use App\Infastructure\Eloquent\User;
use App\Utils\Either;
use Illuminate\Support\Facades\Hash;
use Firebase\JWT\JWT;

class AuthenticationRepositoryImpl implements AuthenticationRepository
{
    public function login(LoginDto $loginDto): Either
    {
        $userRecord = User::where('userName', $loginDto->userName)->first();

        if (!$userRecord || !Hash::check($loginDto->password, $userRecord->password)) {
            $errorResponse = new ErrorResponse(400, 'Invalid credentials');
            return Either::left($errorResponse);
        }

        $user = new UserEntity(
            $userRecord->id,
            $userRecord->name,
            $userRecord->userName,
            $userRecord->profilePictureBlob
        );

        $expirationTime = time() + 3600; // Token expires in 1 hour (3600 seconds)

        $token = JWT::encode(
            payload: ['userName' => $user->userName, 'exp' => $expirationTime],
            key: env('JWT_SECRET', 'defaultsecret'),
            alg: 'HS256',
        );

        $loggedData = new LoggedDataDto(200, $token, $user);

        return Either::right($loggedData);
    }
}

