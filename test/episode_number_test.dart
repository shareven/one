import 'package:flutter_test/flutter_test.dart';
import 'package:one/model/book_model.dart';
import 'package:one/utils/episode_number.dart';

void main() {
  group('parseChinese', () {
    test('个位', () {
      expect(EpisodeNumber.parseChinese('一'), 1);
      expect(EpisodeNumber.parseChinese('九'), 9);
      expect(EpisodeNumber.parseChinese('两'), 2);
      expect(EpisodeNumber.parseChinese('零'), 0);
      expect(EpisodeNumber.parseChinese('〇'), 0);
    });

    test('十位', () {
      expect(EpisodeNumber.parseChinese('十'), 10);
      expect(EpisodeNumber.parseChinese('十五'), 15);
      expect(EpisodeNumber.parseChinese('二十'), 20);
      expect(EpisodeNumber.parseChinese('二十三'), 23);
    });

    test('百位及以上', () {
      expect(EpisodeNumber.parseChinese('一百'), 100);
      expect(EpisodeNumber.parseChinese('一百零八'), 108);
      expect(EpisodeNumber.parseChinese('三百六十五'), 365);
      expect(EpisodeNumber.parseChinese('一千'), 1000);
      expect(EpisodeNumber.parseChinese('三千二百四十三'), 3243);
      expect(EpisodeNumber.parseChinese('一万'), 10000);
      expect(EpisodeNumber.parseChinese('一万零一'), 10001);
      expect(EpisodeNumber.parseChinese('十万'), 100000);
    });

    test('非法输入返回 null', () {
      expect(EpisodeNumber.parseChinese(''), isNull);
      expect(EpisodeNumber.parseChinese('个'), isNull);
    });
  });

  group('keyOf', () {
    test('阿拉伯数字集号', () {
      expect(
        EpisodeNumber.keyOf('从箭术开始修行 第1461集 养马奴，直视我（2）.m4a'),
        [1461],
      );
    });

    test('中文数字集号,书名中的"第X"不误伤', () {
      expect(EpisodeNumber.keyOf('第二人格 第二十二章.ma4'), [22]);
      expect(EpisodeNumber.keyOf('第二人格 第二十二集.ma4'), [22]);
    });

    test('多单位: 章 回 期 卷 季', () {
      expect(EpisodeNumber.keyOf('西游记 第九十八回.m4a'), [98]);
      expect(EpisodeNumber.keyOf('第一卷 第十二章.m4a'), [1, 12]);
      expect(EpisodeNumber.keyOf('第2季 第5集.m4a'), [2, 5]);
      expect(EpisodeNumber.keyOf('神秘电台 第99期.m4a'), [99]);
    });

    test('无集号返回空列表', () {
      expect(EpisodeNumber.keyOf('养马奴，直视我（2）.m4a'), isEmpty);
      expect(EpisodeNumber.keyOf('番外篇 小剧场.ma4'), isEmpty);
      expect(EpisodeNumber.keyOf('序章.mp3'), isEmpty);
    });
  });

  group('trackKeyOf', () {
    test('trackNumber 优先', () {
      expect(EpisodeNumber.trackKeyOf(33, '随便', '随便.m4a'), [33]);
    });

    test('其次标题', () {
      expect(EpisodeNumber.trackKeyOf(0, '第108集', 'x.m4a'), [108]);
    });

    test('最后文件名', () {
      expect(
        EpisodeNumber.trackKeyOf(0, '养马奴，直视我（2）', '书名 第1461集 养马奴.m4a'),
        [1461],
      );
    });

    test('bookName 传递到标题与文件名解析', () {
      expect(
        EpisodeNumber.trackKeyOf(
          0,
          '养马奴，直视我（2）',
          '从箭术开始修行1461.m4a',
          bookName: '从箭术开始修行',
        ),
        [1461],
      );
    });
  });

  group('compareKeys', () {
    test('平级数字比较', () {
      expect(EpisodeNumber.compareKeys([21], [22]), lessThan(0));
      expect(EpisodeNumber.compareKeys([1461], [2343]), lessThan(0));
      expect(EpisodeNumber.compareKeys([99], [100]), lessThan(0));
    });

    test('元组按字典序', () {
      expect(EpisodeNumber.compareKeys([1, 12], [1, 13]), lessThan(0));
      expect(EpisodeNumber.compareKeys([1, 99], [2, 1]), lessThan(0));
      expect(EpisodeNumber.compareKeys([1, 2], [1]), greaterThan(0));
    });
  });

  group('keyOf 剥离书名', () {
    test('书名含"第N集"不毒害层1', () {
      expect(EpisodeNumber.keyOf('第七集档案 第3集.m4a', bookName: '第七集档案'), [3]);
    });

    test('书名含"N集"不毒害层2', () {
      expect(
        EpisodeNumber.keyOf('故事大全1000集 42 标题.m4a', bookName: '故事大全1000集'),
        [42],
      );
    });

    test('书名紧贴集号,后接扩展名', () {
      expect(
        EpisodeNumber.keyOf('从箭术开始修行1461.m4a', bookName: '从箭术开始修行'),
        [1461],
      );
    });

    test('零填充集号解析为数值', () {
      expect(
        EpisodeNumber.keyOf('从箭术开始修行001.m4a', bookName: '从箭术开始修行'),
        [1],
      );
    });

    test('书名紧贴集号+短横线+标题,括号分部号排除', () {
      expect(
        EpisodeNumber.keyOf(
          '从箭术开始修行1461-养马奴，直视我（2）.m4a',
          bookName: '从箭术开始修行',
        ),
        [1461],
      );
    });

    test('书名后跟空格+独立数字', () {
      expect(
        EpisodeNumber.keyOf(
          '从箭术开始修行 1461 养马奴，直视我（2）.m4a',
          bookName: '从箭术开始修行',
        ),
        [1461],
      );
    });

    test('剥离后第N单位(中文数字)仍生效', () {
      expect(
        EpisodeNumber.keyOf('第二人格 第二十二章.ma4', bookName: '第二人格'),
        [22],
      );
    });

    test('文件名等于书名+扩展名时回退', () {
      expect(
        EpisodeNumber.keyOf('三体3死神永生.m4a', bookName: '三体3死神永生'),
        isEmpty,
      );
    });

    test('书名含括号也能剥离', () {
      expect(
        EpisodeNumber.keyOf(
          '凡人修仙传（完本）1461 上集.m4a',
          bookName: '凡人修仙传（完本）',
        ),
        [1461],
      );
    });

    test('不匹配书名时保持完整串匹配', () {
      expect(
        EpisodeNumber.keyOf('abc 1461 xxx.m4a', bookName: '另一个书名'),
        [1461],
      );
    });
  });

  group('keyOf 无书名的裸数字', () {
    test('无"第"字带单位', () {
      expect(EpisodeNumber.keyOf('从箭术开始修行 1461集 养马奴.m4a'), [1461]);
    });

    test('标题以数字开头', () {
      expect(EpisodeNumber.keyOf('1461 养马奴，直视我'), [1461]);
    });

    test('括号内数字是分部号不是集号', () {
      expect(EpisodeNumber.keyOf('养马奴，直视我（2）.m4a'), isEmpty);
      expect(EpisodeNumber.keyOf('养马奴，直视我(2).m4a'), isEmpty);
    });

    test('粘字数字不误判', () {
      expect(EpisodeNumber.keyOf('养马奴2 高清修复.m4a'), isEmpty);
      expect(EpisodeNumber.keyOf('1080P-高清.m4a'), isEmpty);
      expect(EpisodeNumber.keyOf('64kbps-音质.m4a'), isEmpty);
      expect(EpisodeNumber.keyOf('书名1461养马奴.m4a'), isEmpty);
    });

    test('第N单位优先于裸数字', () {
      expect(EpisodeNumber.keyOf('书名 第108集 45'), [108]);
    });
  });

  group('episodeRangeLabel', () {
    test('中文数字集号区间', () {
      final book = BookModel(
        name: '第二人格',
        artUrl: '',
        tracks: [
          AudioTrack(filePath: '/x/第二十二章.ma4', title: '第二十二章'),
          AudioTrack(filePath: '/x/第一章.ma4', title: '第一章'),
          AudioTrack(filePath: '/x/第一百零八章.ma4', title: '第一百零八章'),
        ],
      );
      expect(book.episodeRangeLabel, '1-108集');
    });

    test('阿拉伯数字集号区间,无集号文件跳过', () {
      final book = BookModel(
        name: '从箭术开始修行',
        artUrl: '',
        tracks: [
          AudioTrack(filePath: '/x/第1集.m4a', title: '第1集'),
          AudioTrack(
            filePath: '/x/第1461集 养马奴，直视我（2）.m4a',
            title: '第1461集 养马奴，直视我（2）',
          ),
          AudioTrack(filePath: '/x/第2343集 大结局.m4a', title: '第2343集 大结局'),
        ],
      );
      expect(book.episodeRangeLabel, '1-2343集');
    });

    test('标题无集号时从文件名解析', () {
      final book = BookModel(
        name: 'X',
        artUrl: '',
        tracks: [
          AudioTrack(filePath: '/x/第3集.m4a', title: '养马奴，直视我（2）'),
          AudioTrack(filePath: '/x/第88集.m4a', title: '前情提要'),
        ],
      );
      expect(book.episodeRangeLabel, '3-88集');
    });

    test('全部无集号回退文件数', () {
      final book = BookModel(
        name: 'Y',
        artUrl: '',
        tracks: [
          AudioTrack(filePath: '/a/序章.mp3', title: '序章'),
          AudioTrack(filePath: '/a/番外 小剧场.mp3', title: '番外 小剧场'),
        ],
      );
      expect(book.episodeRangeLabel, '共2集');
    });
  });
}
