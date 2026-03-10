import webWebview from '@ohos.web.webview';
import { SearchEngine, TabItem } from '../model/BrowserModels';
import { browserStore, BrowserStore } from '../store/BrowserStore';

@Entry
@Component
struct Index {
  @State inputText: string = '';
  @State showTabSheet: boolean = false;
  @State showHistorySheet: boolean = false;
  @State showSettingsSheet: boolean = false;
  @State showMenu: boolean = false;
  @State suggestionText: string = '';
  @ObjectLink store: BrowserStore = browserStore;

  private webController: webWebview.WebviewController = new webWebview.WebviewController();

  aboutToAppear(): void {
    this.inputText = this.store.activeTab.url;
  }

  private openByInput(rawInput: string): void {
    if (!rawInput.trim()) {
      return;
    }
    const result = this.store.resolveInputToUrl(rawInput);
    this.store.updateTabState(this.store.activeTab.id, {
      url: result.url,
      loading: true,
      title: rawInput
    });
    this.inputText = result.url;
    this.webController.loadUrl(result.url);
    this.store.addHistory(rawInput, result.url, result.type);
  }

  private openSite(url: string): void {
    this.inputText = url;
    this.openByInput(url);
  }

  private buildTopBar(): void {
    Row({ space: 8 }) {
      TextInput({ text: this.inputText, placeholder: '输入网址或搜索关键词' })
        .layoutWeight(1)
        .onChange((value: string) => {
          this.inputText = value;
          this.suggestionText = value.length > 0 ? `${value}.com` : '';
        })
        .onSubmit(() => this.openByInput(this.inputText));
      Button('前往')
        .type(ButtonType.Capsule)
        .onClick(() => this.openByInput(this.inputText));
    }
    .margin({ top: 10, left: 12, right: 12 });

    if (this.suggestionText.length > 0) {
      Row() {
        Text(`建议：${this.suggestionText}`)
          .fontSize(12)
          .fontColor('#666666');
      }
      .width('100%')
      .padding({ left: 18, top: 4, bottom: 4 });
    }
  }

  private buildHomeSection(): void {
    Column({ space: 10 }) {
      Text('常用网站')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('100%');

      GridRow({ columns: 4, gutter: 8 }) {
        ForEach(this.store.quickSites, (site, index: number) => {
          GridCol({ span: 1 }) {
            Column({ space: 6 }) {
              Text(site.name)
                .fontSize(14)
                .textAlign(TextAlign.Center)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });
              Text(site.url)
                .fontSize(10)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });
            }
            .height(64)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#F4F6F8')
            .borderRadius(12)
            .onClick(() => this.openSite(site.url))
            .gesture(
              LongPressGesture().onAction(() => {
                this.store.removeQuickSite(site.id);
              })
            )
            .gesture(
              PanGesture()
                .onActionEnd((event) => {
                  const move = event.offsetX > 0 ? 1 : -1;
                  this.store.reorderQuickSite(index, index + move);
                })
            );
          };
        });
      }

      Text('最近访问')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ top: 8 });

      List({ space: 6 }) {
        ForEach(this.store.history.slice(0, 8), (item) => {
          ListItem() {
            Row() {
              Column() {
                Text(item.title)
                  .fontSize(13)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
                Text(item.url)
                  .fontSize(11)
                  .fontColor('#666666')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
              }
              .layoutWeight(1);
              Button('打开')
                .onClick(() => this.openSite(item.url));
            }
            .padding(8)
            .borderRadius(8)
            .backgroundColor('#F7F8FA');
          };
        });
      }
      .height(180);
    }
    .padding(12)
    .width('100%');
  }

  private buildWebView(): void {
    Web({ src: this.store.activeTab.url, controller: this.webController })
      .javaScriptAccess(true)
      .domStorageAccess(true)
      .onPageBegin(() => {
        this.store.updateTabState(this.store.activeTab.id, { loading: true });
      })
      .onPageEnd((event) => {
        this.inputText = event.url;
        this.store.updateTabState(this.store.activeTab.id, {
          loading: false,
          url: event.url,
          title: event.title,
          canGoBack: this.webController.accessBackward(),
          canGoForward: this.webController.accessForward()
        });
      })
      .layoutWeight(1)
      .width('100%');
  }

  private buildBottomBar(): void {
    const activeTab: TabItem = this.store.activeTab;
    Row({ space: 10 }) {
      Button('后退')
        .enabled(activeTab.canGoBack)
        .onClick(() => this.webController.backward());
      Button('前进')
        .enabled(activeTab.canGoForward)
        .onClick(() => this.webController.forward());
      Button(activeTab.loading ? '停止' : '刷新')
        .onClick(() => {
          if (activeTab.loading) {
            this.webController.stop();
            this.store.updateTabState(activeTab.id, { loading: false });
            return;
          }
          this.webController.refresh();
        });
      Button(`标签(${this.store.tabs.length})`)
        .onClick(() => {
          this.showTabSheet = true;
        });
      Button('菜单')
        .onClick(() => {
          this.showMenu = !this.showMenu;
        });
    }
    .padding(10)
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor('#FFFFFF');
  }

  @Builder
  private MenuPanel(): void {
    Column({ space: 8 }) {
      Button('新建标签')
        .width('100%')
        .onClick(() => {
          this.store.createTab(false);
          this.inputText = this.store.activeTab.url;
          this.showMenu = false;
        });
      Button('新建无痕标签')
        .width('100%')
        .onClick(() => {
          this.store.createTab(true);
          this.inputText = '';
          this.showMenu = false;
        });
      Button('历史记录').width('100%').onClick(() => {
        this.showHistorySheet = true;
        this.showMenu = false;
      });
      Button('设置').width('100%').onClick(() => {
        this.showSettingsSheet = true;
        this.showMenu = false;
      });
    }
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12);
  }

  @Builder
  private TabSheet(): void {
    Column({ space: 8 }) {
      Row() {
        Text('标签管理').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1);
        Button('+').onClick(() => this.store.createTab(false));
      }
      .width('100%');

      List({ space: 8 }) {
        ForEach(this.store.tabs, (tab) => {
          ListItem() {
            Row({ space: 8 }) {
              Text(tab.isIncognito ? '🕶️' : '🌐');
              Text(tab.title).layoutWeight(1).maxLines(1);
              Button('切换').onClick(() => {
                this.store.switchTab(tab.id);
                this.inputText = this.store.activeTab.url;
                this.showTabSheet = false;
              });
              Button('关闭').onClick(() => this.store.closeTab(tab.id));
            }
            .padding(8)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .gesture(
              PanGesture().onActionEnd((event) => {
                if (Math.abs(event.offsetX) > 30) {
                  this.store.closeTab(tab.id);
                }
              })
            );
          };
        });
      }
      .layoutWeight(1)
      .width('100%');
    }
    .padding(12)
    .height('70%');
  }

  @Builder
  private HistorySheet(): void {
    Column({ space: 8 }) {
      Row() {
        Text('历史记录').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1);
        Button('清空').onClick(() => this.store.clearHistory());
      }.width('100%');

      List({ space: 8 }) {
        ForEach(this.store.history, (item) => {
          ListItem() {
            Row({ space: 8 }) {
              Column() {
                Text(item.title).maxLines(1);
                Text(new Date(item.time).toLocaleString()).fontSize(11).fontColor('#888888');
              }
              .layoutWeight(1);
              Button('打开').onClick(() => {
                this.openSite(item.url);
                this.showHistorySheet = false;
              });
              Button('删除').onClick(() => this.store.removeHistory(item.id));
            }.padding(8);
          };
        });
      }
      .layoutWeight(1)
      .width('100%');
    }
    .padding(12)
    .height('72%');
  }

  @Builder
  private SettingsSheet(): void {
    Column({ space: 12 }) {
      Text('设置').fontSize(20).fontWeight(FontWeight.Bold).width('100%');

      Row() {
        Text('默认搜索引擎').layoutWeight(1);
        Select([{ value: 'Bing' }, { value: 'Baidu' }])
          .selected(this.store.settings.searchEngine === SearchEngine.BING ? 0 : 1)
          .onSelect((index) => {
            this.store.settings.searchEngine = index === 0 ? SearchEngine.BING : SearchEngine.BAIDU;
          });
      }

      Row() {
        Text('Cookie 开关').layoutWeight(1);
        Toggle({ type: ToggleType.Switch, isOn: this.store.settings.cookieEnabled })
          .onChange((isOn) => {
            this.store.settings.cookieEnabled = isOn;
            this.webController.configCookie({ acceptCookie: isOn });
          });
      }

      Button('清除缓存').width('100%').onClick(() => {
        this.webController.clearHistory();
        this.webController.removeCache(true);
      });

      Button('清除历史').width('100%').onClick(() => this.store.clearHistory());
      Text('Nova Browser v1.0.0').fontSize(12).fontColor('#999999');
    }
    .padding(12)
    .height('60%');
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        this.buildTopBar();
        this.buildHomeSection();
        this.buildWebView();
        this.buildBottomBar();
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF');

      if (this.showMenu) {
        this.MenuPanel();
      }
    }
    .bindSheet($$this.showTabSheet, this.TabSheet(), {
      height: SheetSize.MEDIUM,
      showDragBar: true
    })
    .bindSheet($$this.showHistorySheet, this.HistorySheet(), {
      height: SheetSize.LARGE,
      showDragBar: true
    })
    .bindSheet($$this.showSettingsSheet, this.SettingsSheet(), {
      height: SheetSize.MEDIUM,
      showDragBar: true
    });
  }
}
