public with sharing class PhotoUserHierarchy{

    @AuraEnabled(cacheable=true)
    public static List<String> getUsersList() {
    
        Id currentUserId = UserInfo.getUserId();         
        Id currentUserRoleId = UserInfo.getUserRoleId();
        System.debug('List of current User Id and Current User role is:::'+ currentUserId + currentUserRoleId);
        Set<Id> usersIds = new set<Id>();
        // roleHierarchyUtilityClass is the utility class which returns the list of users which are below the role of Current User.
        Set<Id> allUsers = getRoleSubordinateUsers(currentUserRoleId); 
        System.debug('List of all users::'+ allUsers);
        List<String> idStrs = (List<String>)JSON.deserialize(JSON.serialize(allUsers), List<String>.class);
        return idStrs;
    }

    private static Set<ID> getRoleSubordinateUsers(Id roleId) {
        // To get all sub roles.
        Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
        Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where IsActive = True AND UserRoleId IN :allSubRoleIds]);
        return users.keySet();
    }
    
    private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        Set<ID> currentRoleIds = new Set<ID>();
        // Get all the roles underneath the passed roles.
        for(UserRole userRole :[select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null])
            currentRoleIds.add(userRole.Id);
        if(currentRoleIds.size() > 0){
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }
        return currentRoleIds;
    }
}