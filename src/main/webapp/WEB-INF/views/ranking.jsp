<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%@page import="java.util.List"%>

<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>XO Game - Bảng Xếp Hạng</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ranking.css?v=<%= System.currentTimeMillis() %>">
    <link href="https://fonts.googleapis.com/css2?family=Irish+Grover&display=swap" rel="stylesheet">
    <style>
        /* INLINE CRITICAL STYLES - Guarantees instant application immune to browser cache */
        .ranking-page {
            width: 100vw;
            height: 100vh;
            position: relative;
            background-image: url("${pageContext.request.contextPath}/assets/chess_stage.jpg");
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            overflow: hidden;
        }

        .back-button {
            position: absolute !important;
            top: 15px !important;
            left: 20px !important;
            z-index: 20 !important;
            padding: 8px 18px !important;
            border: 3px solid #66813d !important;
            background: rgba(23, 48, 25, 0.92) !important;
            color: #fff0a0 !important;
            font-family: 'Irish Grover', cursive !important;
            font-size: 19px !important;
            cursor: pointer;
            box-shadow: 0 4px 0 #10200f !important;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            transition: 0.2s;
        }
        .back-button:hover {
            transform: scale(1.04);
            background: #35552f !important;
        }

        .rank-info-button {
            position: absolute !important;
            top: 15px !important;
            right: 20px !important;
            z-index: 20 !important;
            padding: 8px 18px !important;
            border: 3px solid #66813d !important;
            background: rgba(23, 48, 25, 0.92) !important;
            color: #ffd700 !important;
            font-family: 'Irish Grover', cursive !important;
            font-size: 17px !important;
            cursor: pointer;
            box-shadow: 0 4px 0 #10200f !important;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: 0.2s;
        }
        .rank-info-button:hover {
            transform: scale(1.04);
            background: #35552f !important;
            color: #fff0a0 !important;
        }

        .ranking-title {
            position: absolute !important;
            top: 12px !important;
            left: 50% !important;
            transform: translateX(-50%) !important;
            z-index: 5 !important;
            color: #fff0a0 !important;
            font-family: 'Irish Grover', cursive !important;
            font-size: 38px !important;
            letter-spacing: 3px;
            text-shadow: 3px 3px 0 #172313, 0 0 8px rgba(255, 240, 160, 0.35);
            white-space: nowrap;
        }

        .ranking-board {
            position: absolute !important;
            top: 68px !important;
            bottom: 15px !important;
            left: 50% !important;
            transform: translateX(-50%) !important;
            z-index: 10 !important;
            width: 800px !important;
            max-width: calc(100vw - 30px) !important;
            display: flex !important;
            flex-direction: column !important;
            background: rgba(18, 43, 23, 0.96) !important;
            border: 4px solid #587734 !important;
            border-radius: 12px !important;
            box-shadow: 0 0 0 5px rgba(20, 38, 18, 0.9), 0 8px 0 #10200f !important;
            overflow: hidden !important;
        }

        .ranking-header {
            flex-shrink: 0 !important;
            height: 48px !important;
            display: grid !important;
            grid-template-columns: 80px 1fr 90px 90px 110px !important;
            align-items: center !important;
            padding: 0 16px !important;
            color: #fff0a0 !important;
            font-family: 'Irish Grover', cursive !important;
            font-size: 18px !important;
            border-bottom: 3px solid #5d7938 !important;
            text-align: center !important;
            background: rgba(14, 34, 18, 0.95) !important;
        }
        .ranking-header div:nth-child(2) {
            text-align: left !important;
        }

        .ranking-body {
            flex: 1 1 auto !important;
            min-height: 0 !important;
            overflow-y: scroll !important;
            overflow-x: hidden !important;
            scrollbar-width: thin !important;
            scrollbar-color: #6a913f rgba(10, 25, 13, 0.9) !important;
        }
        .ranking-body::-webkit-scrollbar {
            width: 10px !important;
        }
        .ranking-body::-webkit-scrollbar-track {
            background: rgba(10, 25, 13, 0.9) !important;
        }
        .ranking-body::-webkit-scrollbar-thumb {
            background: #587734 !important;
            border-radius: 5px !important;
            border: 1px solid #78a248 !important;
        }
        .ranking-body::-webkit-scrollbar-thumb:hover {
            background: #78a248 !important;
        }

        .ranking-row {
            height: 64px !important;
            display: grid !important;
            grid-template-columns: 80px 1fr 90px 90px 110px !important;
            align-items: center !important;
            padding: 0 16px !important;
            color: #e9e9bb !important;
            font-family: 'Irish Grover', cursive !important;
            font-size: 18px !important;
            text-align: center !important;
            border-bottom: 2px solid rgba(84, 112, 52, 0.4) !important;
            transition: background 0.15s ease;
        }
        .ranking-row:last-child {
            border-bottom: none !important;
        }
        .ranking-row:hover {
            background: rgba(0, 232, 120, 0.08) !important;
        }

        .my-ranking-bar,
        .my-ranking {
            flex-shrink: 0 !important;
            position: static !important;
            transform: none !important;
            left: auto !important;
            bottom: auto !important;
            width: 100% !important;
            min-height: 56px !important;
            max-height: 56px !important;
            display: flex !important;
            align-items: center !important;
            justify-content: space-between !important;
            gap: 15px !important;
            padding: 6px 22px !important;
            background: linear-gradient(180deg, rgba(14, 34, 18, 0.98) 0%, rgba(8, 20, 10, 1) 100%) !important;
            border: none !important;
            border-top: 3px solid #5d7938 !important;
            color: #d8dda8 !important;
            font-family: 'Irish Grover', cursive !important;
            box-shadow: 0 -4px 12px rgba(0, 0, 0, 0.5) !important;
            z-index: 15 !important;
            box-sizing: border-box !important;
        }

        @media (max-width: 850px) {
            .ranking-board {
                width: 96% !important;
                top: 65px !important;
                bottom: 10px !important;
            }
            .ranking-header,
            .ranking-row {
                grid-template-columns: 55px 1fr 65px 65px 75px !important;
                padding: 0 10px !important;
                font-size: 15px !important;
            }
            .ranking-title {
                font-size: 26px !important;
                top: 14px !important;
            }
            .back-button, .rank-info-button {
                padding: 6px 12px !important;
                font-size: 14px !important;
                top: 14px !important;
            }
            .my-ranking-bar, .my-ranking {
                padding: 6px 12px !important;
            }
        }
    </style>
</head>

<body>

<div class="ranking-page">

    <!-- BACK -->
    <button class="back-button" onclick="goBack()">
        ← Back
    </button>

    <!-- VIEW RANK TIERS BUTTON -->
    <a href="${pageContext.request.contextPath}/profile?tab=ranks" 
       class="rank-info-button"
       title="Xem chi tiết các mốc điểm và bậc Rank">
        🏆 Bảng Bậc Rank
    </a>

    <!-- TITLE -->
    <div class="ranking-title">
        PLAYER RANKING
    </div>

    <!-- RANKING BOARD -->
    <div class="ranking-board">

        <!-- HEADER -->
        <div class="ranking-header">
            <div>Rank</div>
            <div>Player</div>
            <div>Wins</div>
            <div>Losses</div>
            <div>Rating</div>
        </div>

        <!-- SCROLLABLE LIST BODY -->
        <div class="ranking-body">
            <%
                List<User> rankings = (List<User>) request.getAttribute("rankings");
                if (rankings != null && !rankings.isEmpty()) {
                    int rank = 1;
                    for (User u : rankings) {
                        String rankBadge = String.valueOf(rank);
                        String rowClass = "";
                        if (rank == 1) {
                            rankBadge = "🥇";
                            rowClass = "first";
                        } else if (rank == 2) {
                            rankBadge = "🥈";
                            rowClass = "second";
                        } else if (rank == 3) {
                            rankBadge = "🥉";
                            rowClass = "third";
                        }

                        String avaUrl = u.getAvatarUrl(request.getContextPath());
            %>
                <div class="ranking-row <%= rowClass %>">
                    <div class="rank"><%= rankBadge %></div>
                    <div class="player">
                        <div class="avatar">
                            <img src="<%= avaUrl %>" alt="Avatar" class="ranking-avatar-img">
                        </div>
                        <span><%= u.getNickname() != null ? u.getNickname() : u.getUsername() %></span>
                    </div>
                    <div><%= u.getWins() %></div>
                    <div><%= u.getLosses() %></div>
                    <div class="rating"><%= u.getScore() %></div>
                </div>
            <%
                        rank++;
                    }
                } else {
            %>
                <div class="ranking-empty">
                    Chưa có dữ liệu người chơi!
                </div>
            <% } %>
        </div>

        <!-- CURRENT PLAYER PINNED FOOTER (ALWAYS VISIBLE AT BOTTOM) -->
        <%
            User currentUser = (User) request.getAttribute("currentUser");
            Integer myRank = (Integer) request.getAttribute("myRank");
            if (currentUser != null) {
        %>
        <div class="my-ranking-bar my-ranking">
            <div class="my-rank-left">
                <img src="<%= currentUser.getAvatarUrl(request.getContextPath()) %>" alt="Avatar" class="my-rank-avatar">
                <div class="my-rank-info">
                    <span class="my-rank-label">Xếp hạng của bạn:</span>
                    <strong class="my-rank-num">#<%= myRank != null ? myRank : "-" %></strong>
                </div>
            </div>
            <div class="my-rank-right">
                <span class="my-rank-badge"><%= currentUser.getRankBadge() %></span>
                <span class="my-rank-divider">&bull;</span>
                <span class="my-rank-score">⭐ <%= currentUser.getScore() %> pts</span>
                <span class="my-rank-stats">(Thắng: <%= currentUser.getWins() %> | Thua: <%= currentUser.getLosses() %>)</span>
            </div>
        </div>
        <% } %>

    </div>

</div>

<script src="${pageContext.request.contextPath}/js/ranking.js"></script>

</body>
</html>