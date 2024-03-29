# -*- coding: utf-8 -*-

# ====================================================================================================
#
# makemapdata.py
#
# licence:MIT Licence
# copyright-holders:Hitoshi Iwai(aburi6800)
#
# ====================================================================================================

# 仕様：
# - 各ラウンドデータをアセンブラソースとして出力する。
# - 1バイトに4チップ分のデータを保持する。(1チップ2ビット)

import os

def execute():
    mapList = [
        # ROUND 1
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,3,1,1,1,1,1,1,1,1],
        [0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0],
        [0,0,0,0,1,2,1,2,2,1,2,1,0,0,0,0],
        [0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0],
        [0,0,0,0,1,2,1,2,2,1,2,1,0,0,0,0],
        [0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0],
        [0,0,0,0,1,2,1,2,2,1,2,1,0,0,0,0],
        [0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
    ],[
        # ROUND 2
        [0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0],
        [0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,1,2,2,1,0,0,0],
        [0,0,0,0,0,0,0,0,0,1,2,2,1,0,0,0],
        [0,0,0,0,0,1,1,1,2,1,1,0,0,0,0,0],
        [0,0,0,0,0,1,2,1,1,1,1,0,0,0,0,0],
        [0,0,0,1,1,2,1,0,0,0,0,0,0,0,0,0],
        [0,0,0,1,2,1,1,0,0,0,0,0,0,0,0,0],
        [0,0,0,1,1,2,1,1,2,1,1,3,1,0,0,0],
        [0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    ],[
        # ROUND 3
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,2,2,2,2,0,0,0,0,0,0],
        [0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0],
        [0,0,2,2,1,1,2,1,1,2,1,1,2,2,0,0],
        [0,0,2,2,1,1,1,1,3,1,1,1,2,2,0,0],
        [0,0,2,2,1,1,2,1,1,2,1,1,2,2,0,0],
        [0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0],
        [0,0,0,0,0,0,2,2,2,2,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    ],[
        # ROUND 4
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,1,1,2,1,1,0,0,0,0,0,0,0,0,0,0],
        [0,1,2,1,2,2,1,3,2,2,1,1,0,0,0,0],
        [0,1,1,2,1,1,0,0,0,1,2,2,1,1,1,0],
        [0,0,0,1,0,0,0,0,0,0,1,1,2,1,1,0],
        [0,0,0,2,0,0,0,0,0,0,1,2,1,2,1,0],
        [0,0,0,2,0,0,0,0,0,0,1,1,2,1,1,0],
        [0,0,0,1,0,0,0,0,0,0,1,1,1,1,1,0],
        [0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0],
    ],[
        # ROUND 5
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,1,1,1,0,0,0,1,1,1,0,0,0,0,0,0],
        [0,1,3,1,0,0,0,1,2,1,1,2,2,1,0,0],
        [0,1,1,1,0,0,0,1,1,1,0,0,0,2,0,0],
        [0,0,1,0,0,0,0,0,0,0,0,0,1,1,1,0],
        [0,0,1,0,0,0,0,0,0,0,0,0,2,2,2,0],
        [0,1,1,1,0,0,0,0,0,0,0,0,1,1,1,0],
        [0,2,1,2,0,0,0,0,0,0,0,0,0,1,0,0],
        [0,1,2,1,0,2,2,1,1,2,1,0,0,2,0,0],
        [0,0,1,2,1,1,0,0,1,1,2,1,2,2,0,0],
        [0,0,0,0,0,0,0,0,1,2,1,0,0,0,0,0],
    ],[
        # ROUND 6
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0],
        [0,0,1,1,2,1,2,1,0,0,0,0,0,0,0,0],
        [0,1,1,2,1,2,1,2,1,0,0,0,0,0,0,0],
        [0,1,2,1,2,1,2,1,0,0,0,0,0,0,0,0],
        [0,1,1,1,1,1,0,0,0,0,2,2,0,1,1,0],
        [0,1,2,1,2,1,2,1,0,0,2,2,0,1,3,0],
        [0,1,1,2,1,2,1,2,1,0,0,0,0,0,0,0],
        [0,0,1,1,2,1,2,1,0,0,0,0,0,0,0,0],
        [0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    ],[
        # ROUND 7
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,1,1,0,1,1,1,0,1,2,1,1,2,1,1,0],
        [1,1,1,0,1,1,1,0,1,1,1,1,1,2,1,0],
        [0,1,1,0,1,2,1,0,1,2,1,0,0,1,0,0],
        [0,0,0,0,1,1,1,0,1,1,1,0,1,1,1,0],
        [0,1,1,2,1,1,0,2,0,0,2,1,1,2,1,0],
        [0,1,1,1,1,1,0,0,0,0,1,0,0,0,0,0],
        [0,0,0,1,1,2,0,1,2,1,1,0,0,0,0,0],
        [0,1,2,1,1,2,0,1,2,1,1,0,0,1,1,0],
        [0,1,1,2,1,0,0,1,1,1,1,0,0,1,3,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    ],[
        # ROUND 8
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,2,2,1,1,2,0,2,1,2,2,1,1,0,0],
        [0,2,1,0,0,0,0,0,0,0,0,0,0,2,1,0],
        [0,1,2,0,0,0,0,0,0,0,0,0,0,1,2,0],
        [0,2,1,0,0,0,0,0,0,0,0,0,0,2,1,0],
        [0,0,3,1,1,2,2,1,0,2,2,1,1,1,0,0],
        [0,2,1,0,0,0,0,0,0,0,0,0,0,2,1,0],
        [0,1,2,0,0,0,0,0,0,0,0,0,0,1,2,0],
        [0,2,1,0,0,0,0,0,0,0,0,0,0,2,1,0],
        [0,0,2,1,2,2,2,0,2,2,1,2,2,1,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    ],[
        # ROUND 9
#        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
#        [0,0,0,0,2,1,0,0,1,1,2,0,0,1,2,0],
#        [0,0,0,1,0,0,2,1,2,0,0,1,2,1,1,0],
#        [0,0,0,2,0,0,0,0,0,0,0,0,0,0,2,0],
#        [0,1,1,2,0,0,0,0,0,0,0,0,2,0,1,0],
#        [0,2,2,1,0,0,0,0,3,1,0,0,1,2,0,0],
#        [0,2,1,2,0,0,0,0,2,1,0,0,2,0,0,0],
#        [0,0,1,0,0,0,0,2,1,0,0,0,0,1,0,0],
#        [0,0,0,2,0,2,0,1,2,1,2,0,1,2,0,0],
#        [0,0,0,0,1,0,1,2,0,0,0,1,2,1,0,0],
#        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],

        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,1,1,1,1,0,0,1,1,1,1,1,1,1,1,0],
        [0,1,1,3,1,0,0,1,1,2,2,2,1,1,1,0],
        [0,1,1,1,1,0,0,1,1,2,2,2,1,1,1,0],
        [0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0],
        [0,0,0,0,0,0,1,2,1,1,0,0,0,0,0,0],
        [0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0],
        [0,1,1,2,2,2,1,1,1,0,0,1,1,1,1,0],
        [0,1,1,2,2,2,1,1,1,0,0,1,1,1,1,0],
        [0,0,1,1,1,1,1,1,1,0,0,1,1,1,1,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    ],[
        # ROUND 10
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,2,1,0,2,2,0,0,2,2,0,1,2,0,0],
        [0,0,0,2,0,1,0,0,0,0,1,0,2,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,1,1,0,0,1,3,0,0,2,2,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,2,0,1,0,0,0,0,1,0,2,0,0,0],
        [0,0,2,1,0,2,2,0,0,2,2,0,1,2,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    ],[
        # ROUND 11
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,2,2,1,0,0,1,2,1,0,0,1,1,1,2,0],
        [0,1,1,2,0,0,2,1,0,0,0,0,2,1,3,0],
        [0,0,2,2,0,1,0,0,0,2,0,2,0,1,2,0],
        [0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0],
        [0,2,1,0,0,2,1,1,1,0,0,0,0,0,0,0],
        [0,0,2,2,0,0,1,1,0,1,0,0,0,0,0,0],
        [0,0,2,0,0,0,2,0,0,0,0,0,1,0,2,0],
        [0,0,0,0,0,0,1,2,2,0,0,1,0,2,2,0],
        [0,0,1,2,2,0,0,1,2,0,1,0,2,1,2,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    ],[
        # ROUND 12
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,2,1,0,0,2,2,0,0,2,2,0,0,1,2,0],
        [0,0,2,0,0,1,0,0,0,0,1,0,0,2,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,1,0,0,0,0,0,0,0,0,2,0,0,0],
        [0,0,1,1,1,0,0,1,3,0,0,2,1,2,0,0],
        [0,0,0,1,0,0,0,0,0,0,0,0,2,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,2,0,0,1,0,0,0,0,1,0,0,2,0,0],
        [0,2,1,0,0,2,2,0,0,2,2,0,0,1,2,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    ],[
        # ROUND 13
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0],
        [0,0,1,1,2,1,2,1,1,2,1,2,1,1,0,0],
        [0,1,1,2,1,1,1,1,1,1,1,1,2,1,1,0],
        [0,1,1,1,1,0,0,1,1,0,0,1,1,1,1,0],
        [0,1,2,1,0,0,0,3,1,0,0,0,1,2,1,0],
        [0,1,1,1,1,0,0,1,1,0,0,1,1,1,1,0],
        [0,1,1,2,1,1,1,1,1,1,1,1,2,1,1,0],
        [0,0,1,1,2,1,2,1,1,2,1,2,1,1,0,0],
        [0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    ],[
        # ROUND 14
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,1,1,1,0,0,0,0,1,1,1,0,0,0,0],
        [0,0,1,3,1,0,1,1,0,1,2,1,0,0,0,0],
        [0,0,1,1,1,0,1,1,0,1,1,2,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,2,2,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,2,2,0,0,0],
        [0,0,1,1,1,0,2,2,0,0,0,0,0,0,0,0],
        [0,0,1,2,1,0,2,2,0,1,2,0,0,0,0,0],
        [0,0,1,1,1,0,0,0,0,2,1,0,2,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    ],[
        # ROUND 15
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,3,1,0,0,0,0,0,0,0,0,1,1,1,0,0],
        [0,0,0,0,0,0,0,1,1,0,2,1,2,1,1,0],
        [0,0,1,1,1,0,0,2,2,0,1,1,1,1,1,0],
        [0,1,1,2,1,2,0,2,2,0,1,2,1,2,1,0],
        [0,1,1,1,1,1,0,2,2,0,0,1,1,1,0,0],
        [0,1,2,1,2,1,0,1,1,0,0,0,0,0,0,0],
        [0,0,1,1,1,0,0,0,0,0,0,0,0,2,1,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    ],[
        # ROUND 16
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,1,1,1,1,0,0,0,0,2,2,1,1,0,2,0],
        [0,0,0,1,1,0,0,0,0,1,0,0,0,2,2,0],
        [0,0,0,1,1,0,0,0,0,2,0,0,0,0,1,0],
        [0,0,0,1,1,1,1,1,1,2,3,0,0,0,2,0],
        [0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0],
        [0,1,0,0,0,0,0,0,0,0,0,0,2,1,2,0],
        [0,1,2,0,0,0,0,0,0,0,0,0,1,0,2,0],
        [0,0,1,1,2,1,0,2,1,0,2,2,1,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    ]

    # バッファ
    buffer = ""

    # 各ラウンドのデータを処理
    for round in range(16):
        print("Convert ROUND " + str(round + 1) + " data.")
        # マップリストから対象ラウンドのデータを取得
        map = mapList[round]
        buffer += exchangeAsmData(map, round+1)

    # バッファをファイルに出力
    export(buffer) 


def exchangeAsmData(map, round):
    # バッファの初期設定
    buff = "; ■ラウンド" + str(round) + '\n'
    buff += "MAP_ROUND" + format(round, '02') + ':\n'

    # 全行ループ
    for row in map:
        # 各行ごとの初期設定
        col = 0
        buff += '    DB '

        for col in range(0, 15, 4):
            # col+0〜+3カラムの値を2進数に変換して結合('0b'は除く)
            data = format(row[col], '02b')
            data += format(row[col+1], '02b')
            data += format(row[col+2], '02b')
            data += format(row[col+3], '02b')
            # 16進数の値に変換、先頭に'$'を付与しbuffに追加
            buff += ',' if col > 0 else ''
            buff += '$' + format(int(data, 2), '02x').upper()

        buff += '\n'

    print(buff)
    return buff


def export(buffer):
    '''
    ファイルエクスポート処理
    '''
    # 出力ファイル名
    outFilePath = os.path.normpath(os.path.join(os.path.dirname(__file__), "../msx/mapdata.asm"))

    with open(outFilePath, mode="w") as f:
        f.write(buffer)

    print("export complete.")


if __name__ == "__main__":
    '''
    アプリケーション実行
    '''
    import sys
    execute()

