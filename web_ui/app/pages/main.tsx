import { DrawerComponent } from '../features/authentication/presentation/components/drawer.component';
import { ChatDetails } from '../features/chat/presentation/components/ChatDetails';
import { ChatsList } from '../features/chat/presentation/components/ChatLists';
import { ChatMain } from '../features/chat/presentation/components/ChatMain';

interface MainPageProps {}

export const MainPage: React.FC<MainPageProps> = () => {
  return (
    <div className="flex w-full min-h-screen bg-white">
      <ChatsList />
      <ChatMain />
      <ChatDetails />
    </div>
  );
}