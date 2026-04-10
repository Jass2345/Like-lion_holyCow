import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

const db = admin.firestore();

/**
 * 그룹 멤버가 4명이 되면 자동으로 게임을 시작하고 첫 폭탄을 생성.
 */
export const onGroupMemberJoined = functions.firestore
  .document('groups/{groupId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    const beforeCount: number = (before.memberUids as string[]).length;
    const afterCount: number = (after.memberUids as string[]).length;

    // 4명이 됐을 때만 실행
    if (beforeCount === afterCount) return;
    if (afterCount !== 4) return;
    if (after.status !== 'waiting') return;

    const { groupId } = context.params;
    functions.logger.info(`그룹 ${groupId} 4명 완성 → 게임 시작`);

    const now = admin.firestore.Timestamp.now();
    const expiresAt = new Date(now.toMillis() + 24 * 60 * 60 * 1000); // 24시간 후

    // 첫 폭탄 생성 (첫 번째 멤버가 보유)
    const firstHolder = (after.memberUids as string[])[0];
    const bombRef = db.collection('groups').doc(groupId).collection('bombs').doc();

    const batch = db.batch();

    batch.set(bombRef, {
      id: bombRef.id,
      groupId,
      holderUid: firstHolder,
      receivedAt: now,
      expiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
      status: 'active',
      round: 1,
      explodedUid: null,
    });

    batch.update(change.after.ref, {
      status: 'playing',
      gameStartedAt: now,
    });

    await batch.commit();
    functions.logger.info(`폭탄 생성 완료: ${bombRef.id}, 첫 보유자: ${firstHolder}`);
  });

/**
 * 그룹 생성 시 초기 데이터 세팅 (Callable Function).
 */
export const createGroup = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', '로그인이 필요합니다.');
  }

  const { joinCode } = data as { joinCode: string };
  if (!joinCode || joinCode.length !== 6) {
    throw new functions.https.HttpsError('invalid-argument', '올바른 참여코드가 필요합니다.');
  }

  const uid = context.auth.uid;
  const groupRef = db.collection('groups').doc();

  await groupRef.set({
    id: groupRef.id,
    joinCode: joinCode.toUpperCase(),
    memberUids: [uid],
    status: 'waiting',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    penaltyCount: {},
  });

  return { groupId: groupRef.id };
});
