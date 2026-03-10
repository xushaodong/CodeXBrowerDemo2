export enum SearchEngine {
  BAIDU = 'https://www.baidu.com/s?wd=',
  BING = 'https://cn.bing.com/search?q='
}

export interface QuickSite {
  id: string;
  name: string;
  url: string;
}

export interface TabItem {
  id: number;
  title: string;
  url: string;
  isIncognito: boolean;
  canGoBack: boolean;
  canGoForward: boolean;
  loading: boolean;
}

export interface HistoryRecord {
  id: string;
  title: string;
  url: string;
  time: number;
  type: 'visit' | 'search';
}

export interface BrowserSettings {
  searchEngine: SearchEngine;
  cookieEnabled: boolean;
}
