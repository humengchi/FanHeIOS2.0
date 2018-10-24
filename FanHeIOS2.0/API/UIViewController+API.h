//
//  UIViewController+API.h
//  ChannelPlus
//
//  Created by Peter on 14/12/23.
//  Copyright (c) 2014年 Peter. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"

@class AFHTTPRequestOperation;

//#define HTTP_HOST_DEV       @"api-test.51jinmai.com"
#define HTTP_HOST_DEV   @"api.51jinmai.com"
#define HTTP_HOST_RELEASE   @"api.51jinmai.com"

#if DEBUG==1
#define API_HEADER  [NSString stringWithFormat:@"http://%@", HTTP_HOST_DEV]
#else
#define API_HEADER  [NSString stringWithFormat:@"http://%@", HTTP_HOST_RELEASE]
#endif
typedef NS_ENUM(NSUInteger, RequestType) {
    RequestType_Post,
    RequestType_Get,
    RequestType_Delete,
    RequestType_UPLOAD_IMG,
};

//首页咖啡活动宣传图
#define API_NAME_GET_RCMLIST  @"/v3/post/rcmlisto"//rcmlist

//登录广告
#define API_NAME_GET_LOGIN_ADVERT  @"/v3/ajax/loginAD"

//版本更新
#define API_NAME_GET_VERSION  @"/versionios"

//上传图片
#define API_NAME_UPLOAD_IMAGE  @"/v3/ajax/uploadheadimg"

//更改头像
#define API_NAME_MEMBER_SAVE_IMG  @"/v3/member/saveheadimg"

//保存认证信息,提交认证
#define API_NAME_MEMBER_POST_SUBMIT_MYCARD  @"/v3/member/saveauthenti"

//获取热门业务列表
#define API_NAME_USER_HOT_BUSINESS @"/v3/user/hotbusiness"

//获取认证信息
#define API_NAME_MEMBER_GET_IDENTITYSTART_MYSELF @"/v3/member/getauthenti"

//重新提交认证修改状态
#define API_NAME_MEMBER_POST_CHANGE_MYPHONTEHEADE @"/v3/member/upauthenti_status"

//1.1 根据关键字匹配出 公司名
#define API_NAME_MATCH_PROPERTY_COMPANY  @"/v3/auth/matchProperty/company"

//1.2 根据关键字匹配出 职位名
#define API_NAME_MATCH_PROPERTY_POSITION  @"/v3/auth/matchProperty/position"

//1.3 获取所有行业名称
#define API_NAME_MATCH_PROPERTY_INDUSTRY  @"/v3/auth/matchProperty/industry"

//1.4 根据关键字匹配出 业务名
#define API_NAME_MATCH_PROPERTY_BUSINESS  @"/v3/auth/matchProperty/business"

//1.9 获取access_token
#define API_NAME_ACCESS_TOKEN  @"/oauth/access_token"

//1.10 判断手机号是否注册并发送验证码(忘记密码)
#define API_NAME_SEND_VALID_CODE  @"/v3/auth/sendvalidcode"

//1.11 检查验证码是否正确
#define API_NAME_CHECK_VALID_CODE  @"/v3/auth/checkvalidcode"

//1.12 判断手机号是否注册并发送验证码(注册)
#define API_NAME_REGISTER_PHONE  @"/v3/auth/regphone"

//1.13 重置密码
#define API_NAME_RESET_PASSWD  @"/v3/auth/resetpasswd"

//1.14 密码登陆
#define API_NAME_LOGIN_PASSWD  @"/v3/auth/loginpasswd"

//1.15 验证码登录
#define API_NAME_LOGIN_CODE  @"/v3/auth/logincode"

//1.16 注册账号（姓名，手机，密码）
#define API_NAME_REGISTER  @"/v3/auth/reguser"

//1.17 获取骑牛ToKen
#define API_NAME_USER_GET_QINIUTOKEN  @"/v3/ajax/qiniutoken"

//1.18	获取登入用户的信息
#define API_NAME_USER_GET_USER_INFO  @"/v3/auth/getuserinfo"

//1.19	管理员登录
#define API_NAME_ADMIN_LOGIN  @"/v3/auth/waiterlogin"

//1.20	发送语音验证码
#define API_NAME_SEND_AUDIO_VALID_CODE @"/v3/auth/sendAudioVC"

//2.1 人脉推荐
#define API_NAME_USER_RECOMMEND  @"/v3/user/recomlist"

//2.2 他的主页
#define API_NAME_USER_GET_TAHOMEPAGE  @"/v3/user/otherhome"

//2.4	他的人脉咖啡
#define API_NAME_HIS_READ_COFF_MSG  @"/v3/user/hiscoffee"

//2.5	我的人脉咖啡
#define API_NAME_USER_GET_MYCOFF  @"/v3/user/minecoffee"

//2.6	发送交换名片请求
#define API_NAME_USER_POST_ADDFRIENDS  @"/v3/user/eachcardreq"

//2.7	 删除好友
#define API_NAME_USER_DEL_DELFRIENDS  @"/v3/user/delfriend"

//2.8	同意交换名片请求
#define API_NAME_USER_POST_AGREEADDFRIENDS  @"/v3/user/toeachcard"

//2.9	他的人脉-他关注的用户列表
#define API_NAME_USER_GET_HIS_PEOPLE_HIS_ATTENTION  @"/v3/user/hispeople/hisattention"

//2.10	他的人脉-关注他的用户列表
#define API_NAME_USER_GET_HIS_PEOPLE_ATTENTION_HE  @"/v3/user/hispeople/attentionhe"

//2.11	他的人脉-共同好友的用户列表
#define API_NAME_USER_GET_HIS_PEOPLE_COMMON_FRIEND  @"/v3/user/hispeople/comfriend"

//2.12	全部好友列表
#define API_NAME_USER_GET_ALLFRIENDS  @"/v3/user/getconnectlist"

//2.13	好友搜索
#define API_NAME_USER_SEARCH_ALLFRIENDS  @"/v3/user/friendsearch"

//2.14	人脉推荐咖啡信息和好友请求数
#define API_NAME_USER_RECOMMEND_COFFEE_INFO  @"/v3/user/recommendcoffeeinfo"

//2.15	关注
#define API_NAME_USER_GET_ADDATION  @"/v3/user/attentuser"

//2.16	取消关注
#define API_NAME_USER_GET_CANCELATION  @"/v3/user/unattentuser"

//2.17	领取人脉咖啡并发送消息
#define API_NAME_USER_GET_COFFEE  @"/v3/user/getcoffee"

//2.18 回复咖啡消息
#define API_NAME_USER_REPLY_COFF_MSG  @"/v3/user/replycoffmsg"

//2.19 把咖啡消息标识为已读
#define API_NAME_USER_READ_COFF_MSG  @"/v3/user/readcoffmsg"

//2.20	更新用户最后活跃时间
#define API_NAME_USER_UP_LAST_ACT_TIME  @"/v3/user/uplastacttime"

//2.21	更新用户视频播放次数(+1)
#define API_NAME_USER_UP_VIDEO_PLAY  @"/v3/user/upvideoplay"

//2.22	获取所有用户领取的咖啡总数
#define API_NAME_USER_GET_COFF_COUNT @"/v3/user/gotcoffcount"

//2.23	新消息数量
#define API_NAME_USER_NEW_MSG_COUNT @"/v3/user/newmsgcount"

//2.24	挂出咖啡
#define API_NAME_USER_SHOW_COFFEE @"/v3/user/showcoffee"

//2.25	领取详情 -我领取他人的咖啡
#define API_NAME_USER_RMY_GET_COFFEE_DETAIL  @"/v3/user/mygetcoffeedetail"

//2.26	(扫码)获取人脉咖啡的介绍
#define API_NAME_USER_GET_COFFEE_INTRO  @"/v3/user/getcoffintro"

//2.27	全站搜索人脉搜索
#define API_NAME_USER_SEARCH  @"/v3/user/searchuser"

//2.28	管理员扫码咖啡
#define API_NAME_USER_ADMIN_CK_COFFEE  @"/v3/user/adminckcoffee"

//2.29	修改我的信息-资料编辑
#define API_NAME_SAVE_MY_INFO  @"/v3/auth/saveMyinfo"

//2.30	我的-我领取的咖啡
#define API_NAME_USER_MY_GET_COFFEE_INFO  @"/v3/user/mygetcoffeeinfo"

//2.31	我的-领取我的咖啡
#define API_NAME_USER_GET_MYCOFFEE_INFO  @"/v3/user/getmycoffeeinfo"

//2.32	我的-我被领取咖啡的详情
#define API_NAME_USER_GET_MY_COFFEE_DETAIL  @"/v3/user/getmycoffeedetail"

//2.33	我的人脉-好友申请详情
#define API_NAME_USER_FR_REQUEST_DETAIL  @"/v3/user/frrequestdetail"

 //2.34	管理员确认咖啡兑换（何润祺）
#define API_NAME_MANGER_POST_MAKESURE_EXCHANGECOFFER  @"/v3/user/admingetcoffee"

//2.35	管理员回收咖啡杯（何润祺）
#define API_NAME_MANGER_POST_MAKESURE_GOBACKCOFFER  @"/v3/user/recyclecoffcup"

//2.36	清除新消息提示（CHIN）
#define API_NAME_USER_POST_CLEARMESSAGE @"/v3/user/readnewmsg"

//2.37  我关注的（何润祺）
#define API_NAME_USER_GET_ATTIONMYIFONMATION @"/v3/user/myattention"

//2.38  关注我的（何润祺）
#define API_NAME_USER_GET_MYATTIONOTHERPEOPLE @"/v3/user/attentionme"

//2.39	好友请求列表（CHIN）
#define API_NAME_USER_GET_ASKFRIENDSLIST @"/v3/user/getcardreqlist"

//2.40	删除好友请求（CHIN
#define API_NAME_USER_GET_DELECTFRIENDSASK @"/v3/user/delcardreq"

//2.41	提交问题反馈（CHIN
#define API_NAME_USER_GET_SUBMITQUESTION @"/v3/user/myquestion"

//2.42	手机联系人信息
#define API_NAME_USER_GET_PHONEFRIENDSCONECTION @"/v3/user/getphoneconnect"

//2.43 获取热门业务列表
#define API_NAME_USER_HOT_BUSINESS @"/v3/user/hotbusiness"

//2.44 和领咖啡的人成为好友
#define API_NAME_USER_TOBE_FRIEND @"/v3/user/tobefriend"

//2.45	用户还可以领谁的咖啡
#define API_NAME_USER_CAN_GET_COFFEE @"/v3/user/cangetcoffee"

//2.46	管理员确认挂出咖啡
#define API_NAME_USER_ADMIN_SHOW_COFFEE @"/v3/user/adminshowcoffee"

//2.47	获取兑换券信息
#define API_NAME_USER_ADMIN_GET_CD_KEY_INFO @"/v3/user/getcdkeyinfo"

//2.48	使用兑换券
#define API_NAME_USER_ADMIN_USE_CD_KEY @"/v3/user/usecdkey"

/*===============金脉＋2.3版本，新添加借口==========================*/
#pragma mark -金脉＋2.3版本
//1.1	返回推荐的APP内的优质用户
#define API_NAME_USER_GET_GOOD_USER @"/v3/user/getgooduser"

//3.1	批量添加关注
#define API_NAME_USER_SET_ATTENT_USER @"/v3/user/attentuser"

//3.2	修改个人动态
#define API_NAME_USER_UPDATE_MYSTATE @"/v3/user/upmystate"

//3.3	修改工作经历
#define API_NAME_USER_SAVE_MYCAREER @"/v3/career/savemycareer"

//3.4	获取首页数据
#define API_NAME_USER_GET_HOME_DATA @"/v3/user/index"

//3.7	删除视频
#define API_NAME_AUTH_DELETE_VIDEO @"/v3/auth/delmyvideo"

//3.9	更新分享次数
#define API_NAME_UP_SHARE_CNT @"/v3/user/upsharecnt"

//3.10	看了他的人还看了谁
#define API_NAME_USER_LOOKAT_HISTRY @"/v3/user/visitedwithhim"

//3.11	谁看过我
#define API_NAME_GET_VISITORS @"/v3/user/getvisitors"

//3.17	他的人脉-共同好友头像和数量
#define API_NAME_GET_COMFRIENDS   @"/v3/user/getcomfriendpic"

//3.13	获取全部业务和热门业务
#define API_NAME_GET_ALLHOTBUSINESS  @"/v3/user/getbusiness" 

//3.12	删除工作经历
#define API_NAME_USER_DELECT_MYCAREER  @"/v3/user/delmycareer"

//2.22	点赞活动—活动信息
#define API_NAME_USER_WX_ACTIVITY_INFO @"/v3/user/wxavtinfo"

//2.23	点赞活动—点赞的人列表
#define API_NAME_USER_WX_PRAISEME_LIST  @"/v3/user/wxpraisemelist"

//宣传页面中的推荐人
#define API_NAME_USER_WALL_COFFEE  @"/v3/user/wallcoffee"


//专题接口
//1.0	获取专访列表人气嘉宾
#define API_NAME_MOODSFINANACE_HONORED  @"/v3/post/hotpeople"
//1.1	大家聊金融首页
#define API_NAME_TalkFINANACE_FRIST  @"/v3/post/index"
//1.2	专访列表里的精彩访谈
#define API_NAME_TalkFINANACE_INTERVIEW  @"/v3/post/postlist"
//1.3	资讯详情
#define API_NAME_TalkFINANACE_DETAILINFORMATION  @"/v3/post/postdetail"
//1.4	资讯一级评论页热门评论
#define API_NAME_TalkFINANACE_FRISTHOTRATE  @"/v3/post/postphreviews"
//1.5	资讯一级评论页最新评论
#define API_NAME_TalkFINANACE_FRISTNEWRATE  @"/v3/post/postpnreviews"
//1.6	资讯二级评论页
#define API_NAME_TalkFINANACE_SECOUNDNEWRATE  @"/v3/post/postsreviews"
//1.7	发布资讯评论
#define API_NAME_TalkFINANACE_SENDRATE  @"/v3/post/createpostreview"
//1.8	发布评论的评论
#define API_NAME_GETRATE_SENDRATE   @"/v3/post/createsreview"
//1.9	对资讯点赞
#define API_NAME_TalkFINANACE_LIKEDETAIL  @"/v3/post/postpraise"
//1.10	对资讯的评论点赞
#define API_NAME_TalkFINANACE_GETRATELIKE  @"/v3/post/postreviewpraise"
//1.11	删除一个评论
#define API_NAME_TalkFINANACE_GETDELECTRATE  @"/v3/post/delpostreview"
//1.13	评论点赞列表
#define API_NAME_RATEFINANACE_GETLIKELIST  @"/v3/post/postpraiselist"
//2.20	取消关注话题
#define API_NAME_MYTOPIC_CANCLETOPIC  @"/v3/post/unattentsubject"

//2.21	我关注的话题
#define API_NAME_MYTOPIC_MYATTIONTOPIC  @"/v3/post/myattentsubject"
//2.22	我发起的话题
#define API_NAME_MYTOPIC_MYSTARTTOPIC  @"/v3/post/mysubject"
//2.23	我的观点和评论
#define API_NAME_MYTOPIC_MYVIOWPOINT  @"/v3/post/hisreview"

//2.23	我的通知
#define API_NAME_MYTOPIC_NOTCENTABOUTTOPIC  @"/v3/post/notelist"
//3.25	清空通知列表
#define API_NAME_CLEARALL_NOTCENTABOUTTOPIC  @"/v3/post/clearnote"
/*======================话题======================*/

//3.1	话题详情
#define API_NAME_POST_SUBJECT_DETAIL @"/v3/post/subjectdetail"

//3.2	话题观点列表页
#define API_NAME_POST_VIEWPOINT_LIST @"/v3/post/viewpointlist"

//3.3	好友观点列表页
#define API_NAME_POST_FRIEND_VIEWPOINT @"/v3/post/friendviewpoint"

//3.4	观点详情页
#define API_NAME_POST_VIEWPOINT_DETAIL @"/v3/post/viewpointdetail"

//3.5	观点评论列表
#define API_NAME_POST_VIEWPOINT_REVIEW_LIST @"/v3/post/vpreviewlist"

//3.6	观点点赞列表
#define API_NAME_POST_PRAISE_LIST @"/v3/post/vppraiselist"

//3.7	发表话题
#define API_NAME_POST_ADD_SUBJECT @"/v3/post/addsubject"

//3.8	发表观点
#define API_NAME_POST_ADD_VIEWPOINT @"/v3/post/addviewpoint"

//3.9	发表评论
#define API_NAME_POST_ADD_VP_REVIEW @"/v3/post/addvpreview"

//3.10	评论点赞
#define API_NAME_POST_PRAISE_SUBREVIEW @"/v3/post/praisesubreview"

//3.11	话题内所有参与讨论的人
#define API_NAME_POST_ATWHOIN_SUBJECT @"/v3/post/atwhoinsubject"

//3.12	邀请推荐
#define API_NAME_POST_RECOMD_INVITE @"/v3/post/recomdinvite"

//3.13	邀请搜索
#define API_NAME_POST_INVITE_SEARCH @"/v3/post/invitesearch"

//3.14	删除话题
#define API_NAME_POST_DEL_SUBJECT @"/v3/post/delsubject"

//3.15	删除评论(观点)
#define API_NAME_POST_DEL_SUB_REVIEW @"/v3/post/delsubreview"

//3.16	举报
#define API_NAME_POST_REPORT @"/v3/post/report"

//3.17	邀请回答
#define API_NAME_POST_INVITE_TALK @"/v3/post/invitetalk"

//3.18	话题输入提示
#define API_NAME_POST_SUBJECT_TIP @"/v3/post/subjectintip"

//3.19	关注话题
#define API_NAME_POST_ATTENT_SUBJECT @"/v3/post/attentsubject"

//3.20	取消关注话题
#define API_NAME_POST_UN_ATTENT_SUBJECT @"/v3/post/unattentsubject"

/*======================话题======================*/

/*==================大家聊金融个人主页===============*/
//3.3	话题标签搜索
#define API_NAME_POST_SEARCH_SUBJECT_TAG @"/v3/post/searchsubjecttag"
//3.4	资讯标签搜索
#define API_NAME_POST_SEARCH_POST_TAG @"/v3/post/searchposttag"


/*======================活动======================*/
//1.1	发布（修改）活动
#define API_NAME_POST_Add_ACTIVITY @"/v3/activity/addactivity"
//1.2	活动列表 (CHIN)
#define API_NAME_GET_ACTIVITY_ACTIVITYLIST    @"/v3/activity/searchactivity"
//1.2.1	按照活动场地搜索
#define API_NAME_GET_ACTIVITY_ACTIVITY_LISTS    @"/v3/activity/lists"
//1.3	我报名的活动列表 (CHIN)
#define API_NAME_GET_ACTIVITY_MYACTIVITY    @"/v3/activity/myapplied"
//1.4	活动详情页
#define API_NAME_GET_ACTIVITY_MYACTIVITYDETAIL    @"/v3/activity/detail"
//1.5	活动详情页的问答列表
#define API_NAME_GET_ACTIVITY_ACTIVITYASKLIST    @"/v3/activity/asklist"
//1.6	报名管理列表
#define API_NAME_GET_ACTIVITY_APPLYLIST    @"/v3/activity/applylist"
//1.7	发邮件
#define API_NAME_GET_ACTIVITY_SEND_APPLYLIST    @"/v3/activity/sendapplylist"
//1.8	获取一个活动下的所有报名用户的手机号
#define API_NAME_GET_ACTIVITY_GET_USERPHONE    @"/v3/activity/getactivityuserphone"
//1.9	门票列表
#define API_NAME_GET_ACTIVITY_TICKET_LIST    @"/v3/activity/ticketlist"
//1.10	门票详情------文档中已删除
#define API_NAME_GET_ACTIVITY_TICKET_DETAIL    @"/v3/activity/ticketdetail"
//1.11	报名
#define API_NAME_POST_ACTIVITY_APPLY    @"/v3/activity/apply"
//1.12	报名详情页
#define API_NAME_POST_ACTIVITY_APPLY_DETAIL    @"/v3/activity/applydetail"
//1.13	我报名的活动列表
#define API_NAME_GET_ACTIVITY_MY_APPLY    @"/v3/activity/myactivity"
//1.14	活动管理详情
#define API_NAME_GET_ACTIVITY_MY_ACT_DETAIL    @"/v3/activity/myactdetail"
//1.15	更改报名状态
#define API_NAME_POST_ACTIVITY_UPCAN_APPLY    @"/v3/activity/upcanapply"
//1.16	提问
#define API_NAME_POST_ACTIVITY_ASK    @"/v3/activity/ask"
//1.17	回答
#define API_NAME_POST_ACTIVITY_ANSWER    @"/v3/activity/answer"
//1.17	 活动报道
#define API_NAME_GET_ACTIVITY_REPORT    @"/v3/activity/report"
//1.18	 活动标签搜索
#define API_NAME_GET_ACTIVITYTAGSEARCH    @"/v3/activity/searchtag"
//1.19	 获取搜索标签
#define API_NAME_GET_GETACTIVITYTAGSEARCH    @"/v3/activity/getsearchtag"
//1.20	 活动搜索
#define API_NAME_POST_GETTAGACTIVITY    @"/v3/activity/searchactivitylist"
//1.21	编辑-获取活动信息
#define API_NAME_GET_ACTIVITY_EDIT_INFO    @"/v3/activity/editinfo"
//1.22	通知列表
#define API_NAME_GET_ACTIVITY_NOTE_LIST    @"/v3/activity/notelist"
//1.23	取消、删除活动
#define API_NAME_POST_ACTIVITY_DROP_ATY    @"/v3/activity/dropaty"
//1.24	搜索
#define API_NAME_GET_AJAX_SEARCH    @"/v3/ajax/search"
//1.25	搜索推荐
#define API_NAME_GET_AJAX_HOT_SEARCH    @"/v3/ajax/hotsearch"
//1.26	获取热搜标签
#define API_NAME_GET_AJAX_GET_HOT_SEARCH    @"/v3/ajax/gethotsearch"

/*======================2.4.2加好友，工作经历======================*/
//1.2	工作经历的认证列表
#define  API_NAME_GET_WORKHISTORYLIST_MAP      @"/v3/career/attestationlist"
//1.3	认证工作经历
#define  API_NAME_GET_WORKHISTORY_PROVE    @"/v3/career/attestation"
//1.4	取消认证
#define  API_NAME_GET_WORKHISTORY_CANCEL    @"/v3/career/delattestation"
//1.5	获取链接信息
#define  API_NAME_GET_URLDETAILABOUTALL   @"/v3/career/backurlinfo"
//1.5	获取用户加好友的验证信息
#define API_NAME_GET_TASK_CHECK    @"/v3/user/getaskcheck"
//1.6	验证话题推荐
#define API_NAME_GET_RMD_ASK_CHECK    @"/v3/user/rmdaskcheck"
//1.7	设置个人联系方式是否可见
#define API_NAME_POST_UP_CAN_VIEW_PHONE    @"/v3/user/upcanviewphone"
//1.8	设置加好友的验证方式
#define API_NAME_POST_UP_ASK_CHECK    @"/v3/user/upaskcheck"

/*======================2.4.4======================*/
//1.1	获取所有行业
#define API_NAME_GET_DYNAMIC_INDUSTRY    @"/v3/dynamic/industry"
//1.2	设置用户感兴趣的行业
#define API_NAME_POST_DYNAMIC_SAVE_INDUSTRY    @"/v3/dynamic/saveindustry"
//1.3	推荐关注
#define API_NAME_POST_DYNAMIC_GET_GOODUSER   @"/v3/dynamic/getgooduser"
//1.4	发布动态
#define API_NAME_POST_DYNAMIC_CREATE   @"/v3/dynamic/create"
//1.5	获取#号关键字
#define API_NAME_GET_DYNAMIC_GET_KYWORD   @"/v3/dynamic/getkyword"
//1.6	搜索#号关键字
#define API_NAME_GET_DYNAMIC_SEARCH_KYWORD   @"/v3/dynamic/searchkyword"
//1.7	我的动态列表
#define API_NAME_GET_DYNAMIC_MY_DYNAMIC   @"/v3/dynamic/mydynamic"
//1.8	首页的动态列表
#define API_NAME_POST_DYNAMIC_FEEDDYNAMIC   @"/v3/dynamic/feeddynamic"
//1.9	分享话题生成动态
#define API_NAME_POST_DYNAMIC_SHARE_SUBJECT   @"/v3/dynamic/sharesubjectdynamic"
//1.10	分享活动生成动态
#define API_NAME_POST_DYNAMIC_SHARE_ACTIVITY   @"/v3/dynamic/shareactivitydynamic"
//1.11	分享资讯生成动态
#define API_NAME_POST_DYNAMIC_SHARE_POST   @"/v3/dynamic/sharepostdynamic"
//1.12	分享观点生成动态
#define API_NAME_POST_DYNAMIC_SHARE_GD   @"/v3/dynamic/sharegddynamic"
//1.13	分享资讯评论生成动态
#define API_NAME_POST_DYNAMIC_SHARE_POST_REVIEW   @"/v3/dynamic/sharepostreviewdynamic"
//1.14	分享动态生成动态
#define API_NAME_POST_DYNAMIC_SHARE_DYNAMIC   @"/v3/dynamic/sharedynamic"

//1.16	创建动态的评论
#define API_NAME_POST_DYNAMICDETAILRATELIT_FRIST  @"/v3/dynamic/createdynamicrw"
//1.17	创建动态评论的评论
#define API_NAME_POST_DYNAMICDETAILRATELIT_ECTYPE  @"/v3/dynamic/createreview"
//1.18	对动态点赞
#define API_NAME_POST_DYNAMICDETAILRATELIT_PARSEDNAMIC  @"/v3/dynamic/parsedynamic"
//1.19	对动态的评论点赞
#define API_NAME_POST_DYNAMICDETAILRATELIT_PARSEVIEW  @"/v3/dynamic/parsereview"
//1.20	动态的点赞列表
#define API_NAME_GET_DYNAMICDETAILRATELIT_PARSEVIEWLIST  @"/v3/dynamic/dynamicpraiselist"
//1.21	动态的评论列表
#define API_NAME_GET_DYNAMICDETAILRATELIST  @"/v3/dynamic/reviewlist"
//1.22	动态详情
#define API_NAME_GET_DYNAMICDETAIL  @"/v3/dynamic/dynamicdetail"
//1.23	删除动态
#define API_NAME_DELETE_DYNAMICDETAILRATELIT_DELECTDYNAMIC  @"/v3/dynamic/deldynamic"
//1.24	删除动态评论
#define API_NAME_DELETE_DYNAMICDETAILRATELIT_DELECTRATE  @"/v3/dynamic/deldynamicreview"
//1.25  通知列表
#define API_NAME_POST_DYNAMIC_NOTELIST  @"/v3/dynamic/notelist"
//1.26  点击推荐内容
#define API_NAME_POST_DYNAMIC_CLICK_RCM  @"/v3/dynamic/clickrcmd"
//1.27 不再接收某人动态
#define API_NAME_POST_DYNAMIC_IGNORE_SMB  @"/v3/dynamic/ignoresmb"
//1.28 不再关注某条动态
#define API_NAME_POST_DYNAMIC_IGNORE_DY  @"/v3/dynamic/ignoredy"
//1.29 清空通知列表
#define API_NAME_DELETE_DYNAMIC_CLEARNOTE  @"/v3/dynamic/clearnote"
/***************************2.5*****************************/
//1.获取活动列表中的 专题列表 活动推荐 活动报道
#define API_NAME_ACTIVITY_REPORT    @"/v3/activity/indexlist"
//2.专题下的活动列表
#define API_NAME_SUBJECTREPOIT_REPORTACTIVITY_LIST    @"/v3/activity/subjectatys"
//3.专题下的活动报道列表
#define API_NAME_SUBJECTREPOIT_ACTIVITY_LIST    @"/v3/activity/atyreport"
//4.智能筛选tags列表
#define API_NAME_ACTIVITYCHOSELIST_THRID  @"/v3/activity/gettags"
//6.首页活动直播预告
#define API_NAME_ACTIVITYLIVEVIDEO_LIST  @"/v3/activity/livebroadcast"
//7.活动的城市列表
#define API_NAME_ACTIVITYCITYLIST_GRTCITY  @"/v3/activity/atycitys"

/***************************2.5.1*****************************/
//2.门票列表
#define API_NAME_GET_ACTIVITY_TICKET_LIST  @"/v3/activity/ticketlist"
//3.活动报名
#define API_NAME_POST_ACTIVITY_NEW_APPLY  @"/v3/activity/newapply"
//4.确认支付
#define API_NAME_POST_ACTIVITY_CHECKORDERPAY  @"/v3/activity/checkorderpay"
//5.我的订单
#define API_NAME_GET_ACTIVITY_MY_ORDERS  @"/v3/activity/myorders"
//6.订单详情
#define API_NAME_GET_ACTIVITY_ORDER_DETAIL @"/v3/activity/orderdetail"
//7.报名管理
#define API_NAME_GET_ACTIVITY_APPLY_LISTNEW @"/v3/activity/applylistnew"
//8.报名详情页
#define API_NAME_GET_ACTIVITY_APPLY_DETAILNEW @"/v3/activity/applydetailnew"
//9.取消报名,取消订单,退票
#define API_NAME_POST_ACTIVITY_CANCLE_APPLY @"/v3/activity/celapply"
//10.核对门票信息
#define API_NAME_GET_ACTIVITY_CHECK_TICKET @"/v3/activity/checkticket"

/***************************2.6.0*****************************/
//1.人脉推荐列表
#define API_NAME_POST_USER_RECOMLIST @"/v4/user/recomlist"
//2.推荐行业
#define API_NAME_GET_USER_RECOMINDUSTRY @"/v4/user/rcmdindustry"
//3.同行，同职，同事
#define API_NAME_GET_USER_CONNECTION @"/v4/user/connection"
//4.个人主页
#define API_NAME_GET_USER_OTHERHOME @"/v4/user/otherhome"
//5.他的供需
#define API_NAME_GET_USER_HISGX @"/v4/user/hisgx"
//6.评价好友
#define API_NAME_POST_USER_EVALUATE_SMB @"/v4/user/evaluatesmb"
//7.设定标签和荣誉
#define API_NAME_POST_USER_SETMYTAG @"/v4/user/setmytag"
//8.删除个人荣誉
#define API_NAME_DELETE_USER_DELHONOR @"/v4/user/delhonor"
//9.个人相册
#define API_NAME_GET_USER_ALBUMLIST @"/v4/user/albumlist"
//10.删除个人相册
#define API_NAME_DELETE_USER_DELALBUM @"/v4/user/delalbum"
////11.供需详情
//#define API_NAME_GET_USER_GXDETAIL @"/v4/user/gxdetail"
////12.供需点赞
//#define API_NAME_POST_USER_GXPRAISE @"/v4/user/gxpraise"
////13.供需评论点赞
//#define API_NAME_POST_USER_GXREVIEWPRAISE @"/v4/user/gxreviewpraise"
////14.评论供需
//#define API_NAME_POST_USER_GXREVIEW @"/v4/user/gxreview"
////15.回复评论
//#define API_NAME_POST_USER_GXREVIEWREPLY @"/v4/user/gxreviewreply"
//16.评价列表
#define API_NAME_GET_USER_EVALUATIONS @"/v4/user/evaluations"
////17.供需评论列表
//#define API_NAME_GET_USER_GXREVIEWLIST @"/v4/user/gxreviewlist"
//18.首页好友修改资料提示
#define API_NAME_GET_USER_EDIT_TIP @"/v4/user/edittip"
//19.好友修改资料列表
#define API_NAME_GET_USER_EDIT_LIST @"/v4/user/editlist"
//20.发布供需
#define API_NAME_POST_USER_SENDGX @"/v4/user/sendgx"
//21.删除评价
#define API_NAME_DELETE_USER_EVALUATION @"/v4/user/delevaluation"
//22.供需剩余次数
#define API_NAME_GET_USER_RESTGX @"/v4/user/restgx"
//23.上传相册
#define API_NAME_POST_USER_UPLOAD_ALBUM @"/v4/user/upalbum"
//24.更新通讯录
#define API_NAME_POST_USER_QIEL @"/v4/user/qiel"
//25.更改背景图片
#define API_NAME_POST_USER_SET_BGIMG @"/v4/user/setbgimg"
//26.邀请好友评价
#define API_NAME_POST_USER_GETSMBEV @"/v4/user/getsmbev"
//27.公司主页
#define API_NAME_GET_COMPANY_DETAIL @"/v4/company/detail"

/***************************2.7.0*****************************/
//1.签到
#define API_NAME_POST_TASK_SIGNIN @"/v4/task/signin"
//2.我的任务
#define API_NAME_GET_TASK_LIST @"/v4/task/list"
//3.我的咖啡豆
#define API_NAME_GET_USER_MYCOFFEEBEANS @"/v4/user/mycoffeebeans"
//4.咖啡豆充值包
#define API_NAME_GET_USER_COFFEEBEANSLIST @"/v4/user/coffeebeanslist"
//5.领取任务奖励
#define API_NAME_POST_TASK_GETAWARD @"/v4/task/getaward"
//7.完成特定任务
#define API_NAME_POST_TASK_COMPLETETASK @"/v4/task/completetask"
//8.扫名片
#define API_NAME_POST_USER_SCANCARD @"/v4/user/scancard"
//9.某些功能的剩余次数
#define API_NAME_GET_USER_GETUSERSETTING @"/v4/user/getusersetting"
//10.保存名片
#define API_NAME_POST_USER_SAVECARD @"/v4/user/savecard"
//11.我的名片列表
#define API_NAME_GET_USER_CARDLIST @"/v4/user/cardlist"
//12.名片搜索
#define API_NAME_GET_USER_CARDSEARCH @"/v4/user/cardsearch"
//13.名片添加分组
#define API_NAME_POST_USER_ADDCARDGROUP @"/v4/user/addcardgroup"
//14.我的名片分组
#define API_NAME_GET_USER_MYCARDGROUP @"/v4/user/mycardgroup"
//15.删除名片分组
#define API_NAME_DELETE_USER_DELCARDGROUP @"/v4/user/delcardgroup"
//16.名片分组重命名
#define API_NAME_POST_USER_UPCARDGROUP @"/v4/user/upcardgroup"
//17.名片详情
#define API_NAME_GET_USER_CARDDETAIL @"/v4/user/carddetail"
//18.添加名片备注
#define API_NAME_POST_USER_ADDCARDREMARK @"/v4/user/addcardremark"
//19.删除名片
#define API_NAME_DELETE_USER_DELCARD @"/v4/user/delcard"
//20.添加分组
#define API_NAME_POST_USER_ADDGROUP @"/v4/user/addgroup"
//21.保存分享的名片
#define API_NAME_POST_USER_ADDSHARECARD @"/v4/user/addsharecard"
//22.分组详情
#define API_NAME_GET_USET_GROUPCARDLIST @"/v4/user/groupcardlist"
//23.查询头像名字
#define API_NAME_POST_CHECKUSER_HEADERANDNAME @"/v4/user/mobuserinfo"
//24.金脉头条
#define API_NAME_GET_USER_IMTOPIC @"/v4/user/jmtopic"
//25.首页动态
#define API_NAME_POST_DYNAMIC_FEEDDYNAMIC_V4 @"/v4/dynamic/feeddynamic"
//26.屏蔽推荐动态
#define API_NAME_POST_DYNAMIC_DELRCMD @"/v4/dynamic/delrcmd"
//27.首页推荐内容
#define API_NAME_USER_GET_HOME_DATA_V4 @"/v4/user/index"
//28.新朋友列表
#define API_NAME_USER_GET_DYNAMIC_HISNEWFRIEND @"/v4/dynamic/hisnewfriend"
//29.关注单个行业
#define API_NAME_USER_POST_USER_ATTENTINDUSTRY @"/v4/user/attentindustry"
//30.ios支付验证
#define API_NAME_USER_POST_USER_IAPSECONDVALID @"/v4/user/iapsecondvalid"

typedef void(^SUCCESS_BLOCK)(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud);
typedef void(^FAILURE_BLOCK)(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud);


@interface UIViewController (API)

- (void)cancelAllRequest;

#pragma mark - 同步、异步调用接口
// 请求异步调用，参数对象为字典
- (void)requstType:(RequestType)requestType
           apiName:(NSString *)apiName
        paramDict:(NSMutableDictionary *)paramDict
                hud:(MBProgressHUD *)hud
            success:(SUCCESS_BLOCK)success
            failure:(FAILURE_BLOCK)failure;

@end
