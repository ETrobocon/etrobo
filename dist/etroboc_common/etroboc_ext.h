#ifndef _ETROBOC_EXT_H
#define _ETROBOC_EXT_H

#include <stdint.h>
#include "sil.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * etrboc_ext.h
 * ETロボコン2020 シミュレータ用拡張API
 *
 * copyright: ETロボコン2020実行委員会
 */


// v850でコンパイルしているときにシミュレータとみなす
#ifdef __v850
#define ETROBOC_SIM 1
#endif

/* 全クラス共通の関数 */

/**
 * ETRoboc_notifyCompletedToSimulator() - 競技終了通知
 *
 * <p>シミュレータに競技が終了したことを通知する。必須ではないが、競技の進行を素早くするために、
 * 走行が終わったら呼び出すことを推奨する
 * 実機構成では空関数となる</p>
 *
 */

inline static void ETRoboc_notifyCompletedToSimulator(void)
{
#ifdef ETROBOC_SIM
    sil_wrw_mem((uint32_t*)(0x090F1000+512-32),1);
#endif

}

/* アドバンスト用コース情報取得関数定義　*/

enum ETROBOC_COURSE_INFO_ID {
    ETROBOC_COURSE_INFO_CARD_NUMBER,
    ETROBOC_COURSE_INFO_BLOCK_NUMBER,
    ETROBOC_COURSE_INFO_BLOCK_POS_START,
    ETROBOC_COURSE_INFO_BLOCK_POS_BLACK1 = ETROBOC_COURSE_INFO_BLOCK_POS_START,
    ETROBOC_COURSE_INFO_BLOCK_POS_BLACK2,
    ETROBOC_COURSE_INFO_BLOCK_POS_RED1,
    ETROBOC_COURSE_INFO_BLOCK_POS_RED2,
    ETROBOC_COURSE_INFO_BLOCK_POS_YELLOW1,
    ETROBOC_COURSE_INFO_BLOCK_POS_YELLOW2,
    ETROBOC_COURSE_INFO_BLOCK_POS_BLUE1,
    ETROBOC_COURSE_INFO_BLOCK_POS_BLUE2,
    ETROBOC_COURSE_INFO_BLOCK_POS_GREEN1,
    ETROBOC_COURSE_INFO_BLOCK_POS_GREEN2,
    ETROBOC_COURSE_INFO_BLOCK_POS_END = ETROBOC_COURSE_INFO_BLOCK_POS_GREEN2,
    ETROBOC_COURSE_INFO_MAX = ETROBOC_COURSE_INFO_BLOCK_POS_END
};

/**
 * ETRoboc_getCourceInfo() - コース情報の取得
 * 値が取得できるタイミングは競技規約を参照のこと
 * @version 1.0
 * @author ETロボコン実行委員会
 *
 * infoには以下の値が使用可能です
 * <p> ETROBOC_COURSE_INFO_CARD_NUMBER : 数字カードの数字</p>
 * <p> ETROBOC_COURSE_INFO_BLOCK_NUMBER : 黒ブロックに書かれた数字</p>
 * <p> ETROBOC_COURSE_INFO_BLOCK_POS_BLACK1 〜 ETROBOC_COURSE_INFO_BLOCK_POS_GREEN2 : 各ブロックの位置情報</p>
 *
 * ETROBOC_COURSE_INFO_BLOCK_POS_XXXを指定した際に返ってくる位置情報は以下のようになります。
 * <p>交点サークルの場合: 'A'〜'S'の文字コード</p>
 * <pre>
 *  A  B  C  D
 *  E  F  G  H
 *  J  K  L  M
 *  P  Q  R  S
 * </pre>
 * <br/>
 * <p>ブロックサークルの場合:　'1'〜'8'の文字コード</p>
 * <pre>
 *  1  2  3
 *  4     5
 *  6  7  8
 * </pre>
 *
 * @param info 取得するコース情報のID。
 * @return 上記情報をintの値で返します。コース情報のIDが正しくない場合、-1を返します。<br/>
 * 　　　　　また、数字情報に関してはまだ取得できない場合は0が返ります。アドバンストクラス以外のコースでも0が返ります
 */

inline static int ETRoboc_getCourceInfo(enum ETROBOC_COURSE_INFO_ID info)
{
#ifdef ETROBOC_SIM
    uint32_t *p = 0;
    size_t size = 4;
    switch(info) {
        case ETROBOC_COURSE_INFO_CARD_NUMBER:
            p = (uint32_t*)(0x090F0000+512-32);
            break;
        case ETROBOC_COURSE_INFO_BLOCK_NUMBER:
            p = (uint32_t*)(0x090F0000+516-32);
            break;
        default:
            if ( ETROBOC_COURSE_INFO_BLOCK_POS_START <= info &&
                info <= ETROBOC_COURSE_INFO_BLOCK_POS_END ) {
                    p = (uint32_t*)(0x090F0000+520-32+info-ETROBOC_COURSE_INFO_BLOCK_POS_START);
                    size = 1;
            }
            break;
    }

    if ( p ) {
        return ((size == 4)?(int)sil_rew_mem(p):(int)sil_reb_mem((uint8_t*)p));
    } else {
        return -1;
    }
#else
    // シミュレータ以外では-1を返す
    return -1;

#endif
}


#ifdef __cplusplus
}
#endif

#endif /*!_ETROBOC_ADV_H*/
