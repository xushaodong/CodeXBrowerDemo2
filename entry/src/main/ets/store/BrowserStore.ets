import { BrowserSettings, HistoryRecord, QuickSite, SearchEngine, TabItem } from '../model/BrowserModels';

@Observed
export class BrowserStore {
  private static nextTabId: number = 2;

  tabs: TabItem[] = [
    {
      id: 1,
      title: '新标签页',
      url: 'https://www.harmonyos.com',
      isIncognito: false,
      canGoBack: false,
      canGoForward: false,
      loading: false
    }
  ];
  activeTabId: number = 1;
  history: HistoryRecord[] = [];
  quickSites: QuickSite[] = [
    { id: '1', name: '华为', url: 'https://www.huawei.com' },
    { id: '2', name: 'Bing', url: 'https://cn.bing.com' },
    { id: '3', name: '知乎', url: 'https://www.zhihu.com' },
    { id: '4', name: '掘金', url: 'https://juejin.cn' }
  ];
  settings: BrowserSettings = {
    searchEngine: SearchEngine.BING,
    cookieEnabled: true
  };

  get activeTab(): TabItem {
    const found = this.tabs.find((tab: TabItem) => tab.id === this.activeTabId);
    return found ?? this.tabs[0];
  }

  createTab(isIncognito: boolean = false): void {
    const tab: TabItem = {
      id: BrowserStore.nextTabId++,
      title: isIncognito ? '无痕标签' : '新标签页',
      url: isIncognito ? 'about:blank' : 'https://www.harmonyos.com',
      isIncognito,
      canGoBack: false,
      canGoForward: false,
      loading: false
    };
    this.tabs = [...this.tabs, tab];
    this.activeTabId = tab.id;
  }

  closeTab(tabId: number): void {
    if (this.tabs.length === 1) {
      return;
    }
    const closingTab = this.tabs.find((tab: TabItem) => tab.id === tabId);
    this.tabs = this.tabs.filter((tab: TabItem) => tab.id !== tabId);
    if (this.activeTabId === tabId) {
      this.activeTabId = this.tabs[this.tabs.length - 1].id;
    }
    if (closingTab?.isIncognito) {
      this.history = this.history.filter((item: HistoryRecord) => !item.url.includes('about:blank'));
    }
  }

  switchTab(tabId: number): void {
    this.activeTabId = tabId;
  }

  updateTabState(tabId: number, updates: Partial<TabItem>): void {
    this.tabs = this.tabs.map((tab: TabItem) => (tab.id === tabId ? { ...tab, ...updates } : tab));
  }

  addHistory(title: string, url: string, type: 'visit' | 'search'): void {
    if (this.activeTab.isIncognito) {
      return;
    }
    const item: HistoryRecord = {
      id: `${Date.now()}-${Math.floor(Math.random() * 10000)}`,
      title,
      url,
      time: Date.now(),
      type
    };
    this.history = [item, ...this.history].slice(0, 300);
  }

  removeHistory(id: string): void {
    this.history = this.history.filter((item: HistoryRecord) => item.id !== id);
  }

  clearHistory(): void {
    this.history = [];
  }

  reorderQuickSite(from: number, to: number): void {
    if (from === to || from < 0 || to < 0 || from >= this.quickSites.length || to >= this.quickSites.length) {
      return;
    }
    const sites = [...this.quickSites];
    const [moved] = sites.splice(from, 1);
    sites.splice(to, 0, moved);
    this.quickSites = sites;
  }

  removeQuickSite(id: string): void {
    this.quickSites = this.quickSites.filter((site: QuickSite) => site.id !== id);
  }

  resolveInputToUrl(input: string): { url: string; type: 'visit' | 'search' } {
    const trimmed = input.trim();
    const maybeUrl = /^https?:\/\//i.test(trimmed) || /^[\w.-]+\.[a-z]{2,}$/i.test(trimmed);
    if (maybeUrl) {
      const url = /^https?:\/\//i.test(trimmed) ? trimmed : `https://${trimmed}`;
      return { url, type: 'visit' };
    }
    return {
      url: `${this.settings.searchEngine}${encodeURIComponent(trimmed)}`,
      type: 'search'
    };
  }
}

export const browserStore: BrowserStore = new BrowserStore();
