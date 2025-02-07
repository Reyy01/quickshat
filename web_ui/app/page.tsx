
"use client";
import { Provider } from 'react-redux';
import { store } from '@/app/store'; 
import { HomePage } from './pages/home';

export default function MyApp() {
    return (
      <Provider store={store}>
        <HomePage/> 
      </Provider>
    );
}
